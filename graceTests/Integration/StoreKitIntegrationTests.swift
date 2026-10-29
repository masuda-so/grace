import StoreKit
import StoreKitTest
import XCTest

@testable import grace

/// End-to-end checks that run against the local StoreKit configuration.
final class StoreKitIntegrationTests: XCTestCase {
  @MainActor
  func testConfiguredProductsLoadWithProductionIdentifiers() async throws {
    let session = try await makeSession()
    defer { session.clearTransactions() }

    let client = StoreKitSubscriptionClient(catalog: GraceCommerceCatalog.catalog)
    let products = try await client.loadProducts()
    let productsByID = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })

    XCTAssertEqual(Set(productsByID.keys), GraceCommerceCatalog.catalog.productIDs)
    XCTAssertEqual(
      productsByID[GraceCommerceCatalog.dailyPassProductID]?.renewal,
      .manual(accessDuration: Self.dailyPassDuration)
    )
    XCTAssertEqual(
      productsByID[GraceCommerceCatalog.monthlyProductID]?.renewal,
      .automatic
    )
    XCTAssertEqual(
      productsByID[GraceCommerceCatalog.yearlyProductID]?.renewal,
      .automatic
    )
  }

  @MainActor
  func testClientPurchaseReturnsVerifiedEntitlement() async throws {
    let session = try await makeSession()
    defer { session.clearTransactions() }

    let client = StoreKitSubscriptionClient(catalog: GraceCommerceCatalog.catalog)
    _ = try await client.loadProducts()
    let outcome = try await client.purchase(
      productID: GraceCommerceCatalog.monthlyProductID
    )

    guard case .purchased(let entitlements) = outcome else {
      return XCTFail("Expected StoreKit to complete the purchase.")
    }
    XCTAssertTrue(
      entitlements.activeProductIDs.contains(GraceCommerceCatalog.monthlyProductID)
    )

    var unfinishedProductIDs: Set<String> = []
    try await waitForStoreKitState("monthly purchase to leave unfinished transactions") {
      unfinishedProductIDs.removeAll()
      for await result in Transaction.unfinished {
        if case .verified(let transaction) = result {
          unfinishedProductIDs.insert(transaction.productID)
        }
      }
      return !unfinishedProductIDs.contains(GraceCommerceCatalog.monthlyProductID)
    }
    XCTAssertFalse(unfinishedProductIDs.contains(GraceCommerceCatalog.monthlyProductID))
  }

  @MainActor
  func testEntitlementUpdatesProcessesAndFinishesUnfinishedTransaction() async throws {
    print("StoreKit stream phase \(Date()): create session")
    let session = try await makeSession()
    defer {
      print("StoreKit stream phase \(Date()): request cleanup")
      session.clearTransactions()
      print("StoreKit stream phase \(Date()): cleanup request returned")
    }

    print("StoreKit stream phase \(Date()): create unfinished monthly purchase")
    let seededTransaction = try await session.buyProduct(identifier: GraceCommerceCatalog.monthlyProductID)
    print("StoreKit stream phase \(Date()): inspect unfinished transactions")

    var unfinishedTransactionIDs: Set<UInt64> = []
    try await waitForStoreKitState("seeded monthly purchase to be visible as unfinished before subscribing") {
      unfinishedTransactionIDs.removeAll()
      for await result in Transaction.unfinished {
        if case .verified(let transaction) = result {
          unfinishedTransactionIDs.insert(transaction.id)
        }
      }
      return unfinishedTransactionIDs.contains(seededTransaction.id)
    }
    XCTAssertTrue(unfinishedTransactionIDs.contains(seededTransaction.id))

    print("StoreKit stream phase \(Date()): subscribe to client updates")
    let finishRecorder = TransactionFinishRecorder()
    let client = StoreKitSubscriptionClient(
      catalog: GraceCommerceCatalog.catalog,
      finishTransaction: { transaction in
        await transaction.finish()
        await finishRecorder.record(transaction.id)
      }
    )
    let updates = await client.entitlementUpdates()
    var snapshot: EntitlementSnapshot?
    var didReceiveFirstSnapshot = false
    let receiver = Task { @MainActor in
      var iterator = updates.makeAsyncIterator()
      print("StoreKit stream phase \(Date()): await first snapshot")
      snapshot = await iterator.next()
      if Task.isCancelled {
        print("StoreKit stream phase \(Date()): first receive cancelled")
        return
      }
      didReceiveFirstSnapshot = true
      print("StoreKit stream phase \(Date()): first receive returned")
      // Keep the subscription alive so scope-exit cancellation reaches AsyncStream.
      while !Task.isCancelled {
        guard await iterator.next() != nil else { break }
      }
    }
    defer { receiver.cancel() }
    try await waitForStoreKitState("client stream to return its first snapshot", timeout: .seconds(90)) {
      didReceiveFirstSnapshot
    }

    XCTAssertTrue(
      snapshot?.activeProductIDs.contains(GraceCommerceCatalog.monthlyProductID) == true
    )

    print("StoreKit stream phase \(Date()): confirm transaction completion")
    var didFinishSeededTransaction = false
    try await waitForStoreKitState("seeded monthly transaction to be finished by the client") {
      didFinishSeededTransaction = await finishRecorder.contains(seededTransaction.id)
      unfinishedTransactionIDs.removeAll()
      for await result in Transaction.unfinished {
        if case .verified(let transaction) = result {
          unfinishedTransactionIDs.insert(transaction.id)
        }
      }
      return didFinishSeededTransaction
        && !unfinishedTransactionIDs.contains(seededTransaction.id)
    }
    XCTAssertTrue(didFinishSeededTransaction)
    XCTAssertFalse(unfinishedTransactionIDs.contains(seededTransaction.id))
  }

  @MainActor
  func testRestoreSynchronizesPurchasedEntitlementIntoFreshClient() async throws {
    let session = try await makeSession()
    defer { session.clearTransactions() }

    _ = try await session.buyProduct(identifier: GraceCommerceCatalog.yearlyProductID)
    let client = StoreKitSubscriptionClient(catalog: GraceCommerceCatalog.catalog)
    let restored = try await client.restorePurchases()

    XCTAssertTrue(
      restored.activeProductIDs.contains(GraceCommerceCatalog.yearlyProductID)
    )
  }

  @MainActor
  func testDailyPassUsesPurchaseDateAndInjectedClockAtBoundary() async throws {
    let session = try await makeSession()
    defer { session.clearTransactions() }

    let requestedPurchaseDate = Date(timeIntervalSince1970: 1_750_000_000)
    let transaction = try await session.buyProduct(
      identifier: GraceCommerceCatalog.dailyPassProductID,
      options: [.purchaseDate(requestedPurchaseDate)]
    )
    XCTAssertEqual(
      transaction.purchaseDate.timeIntervalSince1970,
      requestedPurchaseDate.timeIntervalSince1970,
      accuracy: 0.001
    )

    let expiration = transaction.purchaseDate.addingTimeInterval(Self.dailyPassDuration)
    var beforeExpiration = await entitlementSnapshot(at: expiration.addingTimeInterval(-0.001))
    try await waitForStoreKitState("boundary-test purchase to be visible before evaluating expiry") {
      beforeExpiration = await self.entitlementSnapshot(at: expiration.addingTimeInterval(-0.001))
      return beforeExpiration.expirationDates[GraceCommerceCatalog.dailyPassProductID] == expiration
        && beforeExpiration.activeProductIDs.contains(GraceCommerceCatalog.dailyPassProductID)
    }
    let atExpiration = await entitlementSnapshot(at: expiration)
    let afterExpiration = await entitlementSnapshot(at: expiration.addingTimeInterval(0.001))

    XCTAssertEqual(
      beforeExpiration.expirationDates[GraceCommerceCatalog.dailyPassProductID],
      expiration
    )
    XCTAssertTrue(
      beforeExpiration.activeProductIDs.contains(GraceCommerceCatalog.dailyPassProductID)
    )
    XCTAssertFalse(
      atExpiration.activeProductIDs.contains(GraceCommerceCatalog.dailyPassProductID)
    )
    XCTAssertFalse(
      afterExpiration.activeProductIDs.contains(GraceCommerceCatalog.dailyPassProductID)
    )
  }

  @MainActor
  func testAskToBuyReturnsPendingPurchaseOutcome() async throws {
    let session = try await makeSession()
    session.askToBuyEnabled = true
    defer { session.clearTransactions() }

    let client = StoreKitSubscriptionClient(catalog: GraceCommerceCatalog.catalog)
    _ = try await client.loadProducts()
    let outcome = try await client.purchase(
      productID: GraceCommerceCatalog.monthlyProductID
    )

    XCTAssertEqual(outcome, .pending)
  }

  @MainActor
  func testRefundRemovesMonthlyEntitlement() async throws {
    let session = try await makeSession()
    defer { session.clearTransactions() }

    _ = try await session.buyProduct(identifier: GraceCommerceCatalog.monthlyProductID)
    let client = StoreKitSubscriptionClient(catalog: GraceCommerceCatalog.catalog)
    var purchased = await client.currentEntitlements()
    try await waitForStoreKitState("monthly entitlement to be visible before refund") {
      purchased = await client.currentEntitlements()
      return purchased.activeProductIDs.contains(GraceCommerceCatalog.monthlyProductID)
    }
    XCTAssertTrue(
      purchased.activeProductIDs.contains(GraceCommerceCatalog.monthlyProductID)
    )

    let transaction = try testTransaction(
      in: session,
      productID: GraceCommerceCatalog.monthlyProductID
    )
    _ = try session.refundTransaction(identifier: transaction.identifier)

    var refunded = await client.currentEntitlements()
    try await waitForStoreKitState("refunded monthly entitlement to disappear") {
      refunded = await client.currentEntitlements()
      return !refunded.activeProductIDs.contains(GraceCommerceCatalog.monthlyProductID)
    }
    XCTAssertFalse(
      refunded.activeProductIDs.contains(GraceCommerceCatalog.monthlyProductID)
    )
  }

  @MainActor
  func testDailyPassRepurchaseUsesLatestSignedPurchaseDate() async throws {
    let session = try await makeSession()
    defer { session.clearTransactions() }

    let firstPurchaseDate = Date(timeIntervalSince1970: 1_750_000_000)
    let secondPurchaseDate = firstPurchaseDate.addingTimeInterval(60 * 60)
    let firstTransaction = try await session.buyProduct(
      identifier: GraceCommerceCatalog.dailyPassProductID,
      options: [.purchaseDate(firstPurchaseDate)]
    )
    // Observe the actual unfinished StoreKit transaction before checking its removal.
    var unfinishedFirstPurchase: Transaction?
    try await waitForStoreKitState("first daily-pass purchase to appear as unfinished") {
      for await result in Transaction.unfinished {
        if case .verified(let transaction) = result,
           transaction.id == firstTransaction.id {
          unfinishedFirstPurchase = transaction
          return true
        }
      }
      return false
    }
    let transactionToFinish = try XCTUnwrap(unfinishedFirstPurchase)
    // Complete delivery before buying the same pass again.
    await transactionToFinish.finish()
    try await waitForStoreKitState("first daily-pass purchase to finish before repurchase") {
      for await result in Transaction.unfinished {
        if case .verified(let transaction) = result,
           transaction.id == firstTransaction.id {
          return false
        }
      }
      return true
    }
    let secondTransaction = try await session.buyProduct(
      identifier: GraceCommerceCatalog.dailyPassProductID,
      options: [.purchaseDate(secondPurchaseDate)]
    )

    XCTAssertEqual(
      firstTransaction.purchaseDate.timeIntervalSince1970,
      firstPurchaseDate.timeIntervalSince1970,
      accuracy: 0.001
    )
    XCTAssertEqual(
      secondTransaction.purchaseDate.timeIntervalSince1970,
      secondPurchaseDate.timeIntervalSince1970,
      accuracy: 0.001
    )

    let expectedExpiration = secondTransaction.purchaseDate.addingTimeInterval(
      Self.dailyPassDuration
    )
    let evaluationDate = secondTransaction.purchaseDate.addingTimeInterval(1)
    let client = StoreKitSubscriptionClient(
      catalog: GraceCommerceCatalog.catalog,
      now: { evaluationDate }
    )
    var entitlements = await client.currentEntitlements()
    try await waitForStoreKitState("repurchased daily pass to use the latest purchase date") {
      entitlements = await client.currentEntitlements()
      return entitlements.expirationDates[GraceCommerceCatalog.dailyPassProductID] == expectedExpiration
        && entitlements.activeProductIDs.contains(GraceCommerceCatalog.dailyPassProductID)
    }

    XCTAssertEqual(
      entitlements.expirationDates[GraceCommerceCatalog.dailyPassProductID],
      expectedExpiration
    )
    XCTAssertTrue(
      entitlements.activeProductIDs.contains(GraceCommerceCatalog.dailyPassProductID)
    )
  }

  @MainActor
  func testDisablingAutoRenewKeepsAccessUntilSubscriptionExpires() async throws {
    let session = try await makeSession()
    defer { session.clearTransactions() }

    _ = try await session.buyProduct(identifier: GraceCommerceCatalog.monthlyProductID)
    let transaction = try testTransaction(
      in: session,
      productID: GraceCommerceCatalog.monthlyProductID
    )
    let client = StoreKitSubscriptionClient(catalog: GraceCommerceCatalog.catalog)

    try await waitForStoreKitState("monthly entitlement to be visible before disabling auto renew") {
      let purchased = await client.currentEntitlements()
      return purchased.activeProductIDs.contains(GraceCommerceCatalog.monthlyProductID)
    }

    _ = try session.disableAutoRenewForTransaction(identifier: transaction.identifier)
    let afterDisablingAutoRenew = await client.currentEntitlements()
    XCTAssertTrue(
      afterDisablingAutoRenew.activeProductIDs.contains(
        GraceCommerceCatalog.monthlyProductID
      )
    )

    _ = try session.expireSubscription(
      productIdentifier: GraceCommerceCatalog.monthlyProductID
    )
    var afterExpiration = await client.currentEntitlements()
    try await waitForStoreKitState("expired monthly entitlement to disappear") {
      afterExpiration = await client.currentEntitlements()
      return !afterExpiration.activeProductIDs.contains(GraceCommerceCatalog.monthlyProductID)
    }
    XCTAssertFalse(
      afterExpiration.activeProductIDs.contains(GraceCommerceCatalog.monthlyProductID)
    )
  }

  /// Waits for observable StoreKit state without treating a timeout as success.
  @MainActor
  private func waitForStoreKitState(
    _ description: String,
    timeout: Duration = .seconds(30),
    condition: @MainActor () async -> Bool
  ) async throws {
    let clock = ContinuousClock()
    let started = clock.now
    let deadline = started.advanced(by: timeout)
    while clock.now < deadline {
      let matched = await condition()
      let observed = clock.now
      if observed >= deadline { break }
      if matched {
        print("StoreKit state confirmed after \(started.duration(to: observed)): \(description)")
        return
      }
      try await clock.sleep(for: .milliseconds(100))
    }
    print("StoreKit state timed out after \(started.duration(to: clock.now)): \(description)")
    XCTFail("Timed out waiting for StoreKit state: \(description)")
    throw StoreKitStateWaitError.timedOut
  }

  private enum StoreKitStateWaitError: Error {
    case timedOut
  }

  private static let dailyPassDuration: TimeInterval = 24 * 60 * 60

  @MainActor
  private func makeSession() async throws -> SKTestSession {
    print("StoreKit fixture phase \(Date()): create and reset session")
    let session = try SKTestSession(
      contentsOf: TestResources.url(forResource: "StoreKit", withExtension: "storekit")
    )
    session.resetToDefaultState()
    session.clearTransactions()
    session.disableDialogs = true
    print("StoreKit fixture phase \(Date()): confirm cleared transaction state")
    try await waitForStoreKitState("clean test fixture in StoreKitTest and StoreKit") {
      guard session.allTransactions().isEmpty else { return false }
      for await _ in Transaction.unfinished { return false }
      for await _ in Transaction.currentEntitlements { return false }
      return true
    }
    print("StoreKit fixture phase \(Date()): cleared transaction state confirmed")
    return session
  }

  private func testTransaction(
    in session: SKTestSession,
    productID: String
  ) throws -> SKTestTransaction {
    try XCTUnwrap(
      session.allTransactions().first { $0.productIdentifier == productID }
    )
  }

  @MainActor
  private func entitlementSnapshot(at date: Date) async -> EntitlementSnapshot {
    let client = StoreKitSubscriptionClient(
      catalog: GraceCommerceCatalog.catalog,
      now: { date }
    )
    return await client.currentEntitlements()
  }

}

private actor TransactionFinishRecorder {
  private var transactionIDs: Set<UInt64> = []

  func record(_ transactionID: UInt64) {
    transactionIDs.insert(transactionID)
  }

  func contains(_ transactionID: UInt64) -> Bool {
    transactionIDs.contains(transactionID)
  }
}

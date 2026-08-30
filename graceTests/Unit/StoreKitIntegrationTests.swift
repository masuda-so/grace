import StoreKit
import StoreKitTest
import XCTest

@testable import grace

/// End-to-end checks that run against the local StoreKit configuration.
final class StoreKitIntegrationTests: XCTestCase {
  @MainActor
  func testConfiguredProductsLoadWithProductionIdentifiers() async throws {
    let session = try makeSession()
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
    let session = try makeSession()
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
    for await result in Transaction.unfinished {
      if case .verified(let transaction) = result {
        unfinishedProductIDs.insert(transaction.productID)
      }
    }
    XCTAssertFalse(unfinishedProductIDs.contains(GraceCommerceCatalog.monthlyProductID))
  }

  @MainActor
  func testEntitlementUpdatesProcessesAndFinishesUnfinishedTransaction() async throws {
    let session = try makeSession()
    defer { session.clearTransactions() }

    _ = try await session.buyProduct(identifier: GraceCommerceCatalog.monthlyProductID)

    var unfinishedProductIDs: Set<String> = []
    for await result in Transaction.unfinished {
      if case .verified(let transaction) = result {
        unfinishedProductIDs.insert(transaction.productID)
      }
    }
    XCTAssertTrue(unfinishedProductIDs.contains(GraceCommerceCatalog.monthlyProductID))

    let client = StoreKitSubscriptionClient(catalog: GraceCommerceCatalog.catalog)
    let updates = await client.entitlementUpdates()
    var iterator = updates.makeAsyncIterator()
    let snapshot = await iterator.next()

    XCTAssertTrue(
      snapshot?.activeProductIDs.contains(GraceCommerceCatalog.monthlyProductID) == true
    )

    unfinishedProductIDs.removeAll()
    for await result in Transaction.unfinished {
      if case .verified(let transaction) = result {
        unfinishedProductIDs.insert(transaction.productID)
      }
    }
    XCTAssertFalse(unfinishedProductIDs.contains(GraceCommerceCatalog.monthlyProductID))
  }

  @MainActor
  func testRestoreSynchronizesPurchasedEntitlementIntoFreshClient() async throws {
    let session = try makeSession()
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
    let session = try makeSession()
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
    let beforeExpiration = await entitlementSnapshot(at: expiration.addingTimeInterval(-0.001))
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
    let session = try makeSession()
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
    let session = try makeSession()
    defer { session.clearTransactions() }

    _ = try await session.buyProduct(identifier: GraceCommerceCatalog.monthlyProductID)
    let client = StoreKitSubscriptionClient(catalog: GraceCommerceCatalog.catalog)
    let purchased = await client.currentEntitlements()
    XCTAssertTrue(
      purchased.activeProductIDs.contains(GraceCommerceCatalog.monthlyProductID)
    )

    let transaction = try testTransaction(
      in: session,
      productID: GraceCommerceCatalog.monthlyProductID
    )
    _ = try session.refundTransaction(identifier: transaction.identifier)

    let refunded = await client.currentEntitlements()
    XCTAssertFalse(
      refunded.activeProductIDs.contains(GraceCommerceCatalog.monthlyProductID)
    )
  }

  @MainActor
  func testDailyPassRepurchaseUsesLatestSignedPurchaseDate() async throws {
    let session = try makeSession()
    defer { session.clearTransactions() }

    let firstPurchaseDate = Date(timeIntervalSince1970: 1_750_000_000)
    let secondPurchaseDate = firstPurchaseDate.addingTimeInterval(60 * 60)
    let firstTransaction = try await session.buyProduct(
      identifier: GraceCommerceCatalog.dailyPassProductID,
      options: [.purchaseDate(firstPurchaseDate)]
    )
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
    let entitlements = await client.currentEntitlements()

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
    let session = try makeSession()
    defer { session.clearTransactions() }

    _ = try await session.buyProduct(identifier: GraceCommerceCatalog.monthlyProductID)
    let transaction = try testTransaction(
      in: session,
      productID: GraceCommerceCatalog.monthlyProductID
    )
    let client = StoreKitSubscriptionClient(catalog: GraceCommerceCatalog.catalog)

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
    let afterExpiration = await client.currentEntitlements()
    XCTAssertFalse(
      afterExpiration.activeProductIDs.contains(GraceCommerceCatalog.monthlyProductID)
    )
  }

  private static let dailyPassDuration: TimeInterval = 24 * 60 * 60

  private func makeSession() throws -> SKTestSession {
    let session = try SKTestSession(contentsOf: storeKitConfigurationURL)
    session.resetToDefaultState()
    session.clearTransactions()
    session.disableDialogs = true
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

  private var storeKitConfigurationURL: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appendingPathComponent("grace", isDirectory: true)
      .appendingPathComponent("Resources", isDirectory: true)
      .appendingPathComponent("StoreKit", isDirectory: true)
      .appendingPathComponent("StoreKit.storekit", isDirectory: false)
  }
}

import StoreKit
import XCTest

@testable import grace

final class CommercePlatformTests: XCTestCase {
  func testStoreKitConfigurationMatchesCatalog() throws {
    let configurationURL = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appendingPathComponent("grace", isDirectory: true)
      .appendingPathComponent("Resources", isDirectory: true)
      .appendingPathComponent("StoreKit", isDirectory: true)
      .appendingPathComponent("StoreKit.storekit", isDirectory: false)
    let data = try Data(contentsOf: configurationURL)
    let configuration = try JSONSerialization.jsonObject(with: data)

    XCTAssertEqual(
      productIdentifiers(in: configuration),
      GraceCommerceCatalog.catalog.productIDs
    )
  }

  func testPreviewClientCoversProductsRestoreAndUpdates() async throws {
    let client = PreviewSubscriptionClient()
    let products = try await client.loadProducts()

    XCTAssertEqual(Set(products.map(\.id)), GraceCommerceCatalog.catalog.productIDs)

    for productID in GraceCommerceCatalog.catalog.productIDs {
      let outcome = try await client.purchase(productID: productID)
      guard case .purchased(let snapshot) = outcome else {
        return XCTFail("Expected a purchased outcome for \(productID).")
      }
      XCTAssertTrue(snapshot.activeProductIDs.contains(productID))
    }

    let restored = try await client.restorePurchases()
    XCTAssertTrue(restored.activeProductIDs.isEmpty)

    let updates = await client.entitlementUpdates()
    var iterator = updates.makeAsyncIterator()
    let firstUpdate = await iterator.next()
    let secondUpdate = await iterator.next()
    XCTAssertEqual(firstUpdate?.activeProductIDs, [])
    XCTAssertNil(secondUpdate)
  }

  func testCatalogValidatesPremiumProducts() throws {
    let catalog = try SubscriptionCatalog.make(
      productIDs: ["monthly", "yearly"],
      premiumProductIDs: ["monthly", "yearly"]
    )

    XCTAssertEqual(catalog.productIDs, ["monthly", "yearly"])
  }

  func testStoreKitClientSeparatesVerifiedAndUnverifiedValues() throws {
    let verifiedResult: VerificationResult<Int> = .verified(42)
    XCTAssertEqual(
      try StoreKitSubscriptionClient.verifiedValue(from: verifiedResult),
      42
    )

    let unverifiedResult: VerificationResult<Int> = .unverified(
      42,
      .invalidSignature
    )

    XCTAssertThrowsError(
      try StoreKitSubscriptionClient.verifiedValue(from: unverifiedResult)
    ) { error in
      XCTAssertEqual(error as? SubscriptionError, .failedVerification)
    }
  }

  func testStoreKitClientMapsPendingAndCancelledPurchaseResults() async throws {
    let pending = try await StoreKitSubscriptionClient.purchaseOutcome(
      from: Product.PurchaseResult.pending
    ) { _ in
      throw SubscriptionError.failedVerification
    }
    let cancelled = try await StoreKitSubscriptionClient.purchaseOutcome(
      from: Product.PurchaseResult.userCancelled
    ) { _ in
      throw SubscriptionError.failedVerification
    }

    XCTAssertEqual(pending, .pending)
    XCTAssertEqual(cancelled, .userCancelled)
  }

  func testCommerceErrorsDoNotExposeInternalIdentifiersOrDiagnostics() {
    let productID = "INTERNAL_PRODUCT_IDENTIFIER"
    let diagnostic = "INTERNAL_STORE_DIAGNOSTIC"

    XCTAssertFalse(
      SubscriptionError.unknownProduct(
        productID: productID
      ).localizedDescription.contains(productID)
    )
    XCTAssertFalse(
      SubscriptionError.storeUnavailable(
        debugDescription: diagnostic
      ).localizedDescription.contains(diagnostic)
    )
  }

  func testCatalogRejectsUnknownPremiumProduct() {
    XCTAssertThrowsError(
      try SubscriptionCatalog.make(
        productIDs: ["monthly"],
        premiumProductIDs: ["yearly"]
      )
    ) { error in
      XCTAssertEqual(error as? SubscriptionError, .invalidCatalog)
    }
  }

  func testEntitlementSnapshotMapsPremiumAccess() throws {
    let catalog = try SubscriptionCatalog.make(
      productIDs: ["monthly", "yearly"],
      premiumProductIDs: ["monthly", "yearly"]
    )
    let snapshot = EntitlementSnapshot(activeProductIDs: ["monthly"])

    XCTAssertTrue(snapshot.hasPremiumAccess(in: catalog))
  }

  func testCatalogCalculatesOneDayPassExpiration() throws {
    let day: TimeInterval = 24 * 60 * 60
    let catalog = try SubscriptionCatalog.make(
      productIDs: ["daily"],
      premiumProductIDs: ["daily"],
      nonRenewingDurations: ["daily": day]
    )
    let purchaseDate = Date(timeIntervalSince1970: 1_000)

    XCTAssertEqual(
      catalog.expirationDate(for: "daily", purchasedAt: purchaseDate),
      purchaseDate.addingTimeInterval(day)
    )
  }

  func testCatalogRejectsInvalidPassDuration() {
    XCTAssertThrowsError(
      try SubscriptionCatalog.make(
        productIDs: ["daily"],
        premiumProductIDs: ["daily"],
        nonRenewingDurations: ["daily": 0]
      )
    ) { error in
      XCTAssertEqual(error as? SubscriptionError, .invalidCatalog)
    }
  }

  func testDailyPassExpiresAtItsBoundary() throws {
    let catalog = try SubscriptionCatalog.make(
      productIDs: ["daily"],
      premiumProductIDs: ["daily"],
      nonRenewingDurations: ["daily": 24 * 60 * 60]
    )
    let expiration = Date(timeIntervalSince1970: 100_000)
    let snapshot = EntitlementSnapshot(
      activeProductIDs: ["daily"],
      expirationDates: ["daily": expiration]
    )

    XCTAssertTrue(
      snapshot.hasPremiumAccess(
        in: catalog,
        at: expiration.addingTimeInterval(-1)
      )
    )
    XCTAssertFalse(snapshot.hasPremiumAccess(in: catalog, at: expiration))
    XCTAssertFalse(
      snapshot.hasPremiumAccess(
        in: catalog,
        at: expiration.addingTimeInterval(1)
      )
    )

    let purchaseDate = expiration.addingTimeInterval(-(24 * 60 * 60))
    XCTAssertNotNil(
      catalog.activeExpirationDate(
        for: "daily",
        purchasedAt: purchaseDate,
        at: expiration.addingTimeInterval(-1)
      )
    )
    XCTAssertNil(
      catalog.activeExpirationDate(
        for: "daily",
        purchasedAt: purchaseDate,
        at: expiration
      )
    )
    XCTAssertNil(
      catalog.activeExpirationDate(
        for: "daily",
        purchasedAt: purchaseDate,
        at: expiration.addingTimeInterval(1)
      )
    )
  }

  func testAutoRenewableAccessDoesNotUseLocalExpirationFiltering() throws {
    let catalog = try SubscriptionCatalog.make(
      productIDs: ["monthly", "yearly"],
      premiumProductIDs: ["monthly", "yearly"]
    )
    for productID in ["monthly", "yearly"] {
      let snapshot = EntitlementSnapshot(
        activeProductIDs: [productID],
        expirationDates: [productID: .distantPast]
      )

      XCTAssertTrue(snapshot.hasPremiumAccess(in: catalog))
    }
  }

  private func productIdentifiers(in value: Any) -> Set<String> {
    if let dictionary = value as? [String: Any] {
      return dictionary.reduce(into: []) { result, element in
        if element.key == "productID", let identifier = element.value as? String {
          result.insert(identifier)
        } else {
          result.formUnion(productIdentifiers(in: element.value))
        }
      }
    }
    if let array = value as? [Any] {
      return array.reduce(into: []) { result, element in
        result.formUnion(productIdentifiers(in: element))
      }
    }
    return []
  }
}

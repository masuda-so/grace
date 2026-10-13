import Foundation

/// Supplies deterministic products and entitlements to SwiftUI previews.
actor PreviewSubscriptionClient: SubscriptionClient {
  func loadProducts() async throws -> [SubscriptionProduct] {
    [
      SubscriptionProduct(
        id: GraceCommerceCatalog.dailyPassProductID,
        displayName: "Grace Pro Daily Pass",
        description: "One-time Pro access for 24 hours.",
        displayPrice: "$0.99",
        renewal: .manual(accessDuration: 24 * 60 * 60)
      ),
      SubscriptionProduct(
        id: GraceCommerceCatalog.monthlyProductID,
        displayName: "Grace Pro Monthly",
        description: "A preview subscription product.",
        displayPrice: "$2.99"
      ),
      SubscriptionProduct(
        id: GraceCommerceCatalog.yearlyProductID,
        displayName: "Grace Pro Yearly",
        description: "A preview subscription product.",
        displayPrice: "$29.99"
      ),
    ]
  }

  func purchase(productID: String) async throws -> PurchaseOutcome {
    let expirationDates: [String: Date]
    if productID == GraceCommerceCatalog.dailyPassProductID {
      expirationDates = [productID: .now.addingTimeInterval(24 * 60 * 60)]
    } else {
      expirationDates = [:]
    }

    return .purchased(
      EntitlementSnapshot(
        activeProductIDs: [productID],
        expirationDates: expirationDates
      )
    )
  }

  func currentEntitlements() async -> EntitlementSnapshot {
    EntitlementSnapshot()
  }

  func restorePurchases() async throws -> EntitlementSnapshot {
    EntitlementSnapshot()
  }

  func entitlementUpdates() async -> AsyncStream<EntitlementSnapshot> {
    AsyncStream { continuation in
      continuation.yield(EntitlementSnapshot())
      continuation.finish()
    }
  }
}

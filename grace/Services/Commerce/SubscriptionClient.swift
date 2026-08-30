/// The StoreKit operations used by the application.
nonisolated protocol SubscriptionClient: Sendable {
  /// Loads the products configured for this application.
  func loadProducts() async throws -> [SubscriptionProduct]

  /// Presents the App Store purchase flow for a product identifier.
  func purchase(productID: String) async throws -> PurchaseOutcome

  /// Returns a snapshot derived only from verified StoreKit transactions.
  func currentEntitlements() async -> EntitlementSnapshot

  /// Synchronizes App Store transactions and returns the resulting entitlements.
  func restorePurchases() async throws -> EntitlementSnapshot

  /// Emits entitlement snapshots as relevant StoreKit transactions change.
  func entitlementUpdates() async -> AsyncStream<EntitlementSnapshot>
}

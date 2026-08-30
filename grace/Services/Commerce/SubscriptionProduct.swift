import Foundation

/// Describes whether StoreKit renews a product automatically.
nonisolated enum SubscriptionRenewal: Equatable, Sendable {
  case automatic
  case manual(accessDuration: TimeInterval)
}

/// The product information needed by the paywall.
nonisolated struct SubscriptionProduct: Identifiable, Equatable, Sendable {
  let id: String
  let displayName: String
  let description: String
  let displayPrice: String
  let renewal: SubscriptionRenewal

  init(
    id: String,
    displayName: String,
    description: String,
    displayPrice: String,
    renewal: SubscriptionRenewal = .automatic
  ) {
    self.id = id
    self.displayName = displayName
    self.description = description
    self.displayPrice = displayPrice
    self.renewal = renewal
  }
}

/// A point-in-time view of the person's verified StoreKit entitlements.
nonisolated struct EntitlementSnapshot: Equatable, Sendable {
  let activeProductIDs: Set<String>
  let expirationDates: [String: Date]
  let refreshedAt: Date

  init(
    activeProductIDs: Set<String> = [],
    expirationDates: [String: Date] = [:],
    refreshedAt: Date = .now
  ) {
    self.activeProductIDs = activeProductIDs
    self.expirationDates = expirationDates
    self.refreshedAt = refreshedAt
  }

  /// Returns whether a product grants access at a specific wall-clock date.
  func isActive(
    productID: String,
    in catalog: SubscriptionCatalog,
    at date: Date = .now
  ) -> Bool {
    guard activeProductIDs.contains(productID) else { return false }
    guard catalog.nonRenewingDurations[productID] != nil else { return true }
    return expirationDates[productID].map { $0 > date } ?? false
  }

  /// Returns whether any premium product grants access at a specific date.
  func hasPremiumAccess(
    in catalog: SubscriptionCatalog,
    at date: Date = .now
  ) -> Bool {
    catalog.premiumProductIDs.contains {
      isActive(productID: $0, in: catalog, at: date)
    }
  }

  /// Returns the next locally calculated expiration for an active nonrenewing product.
  func nextNonRenewingExpiration(
    in catalog: SubscriptionCatalog,
    after date: Date = .now
  ) -> Date? {
    catalog.nonRenewingDurations.keys
      .compactMap { productID in
        guard isActive(productID: productID, in: catalog, at: date) else {
          return nil
        }
        return expirationDates[productID]
      }
      .min()
  }
}

/// The possible outcomes from StoreKit's purchase sheet.
nonisolated enum PurchaseOutcome: Equatable, Sendable {
  case purchased(EntitlementSnapshot)
  case pending
  case userCancelled
}

/// Errors that can be safely presented by the commerce UI.
nonisolated enum SubscriptionError: Error, Equatable, Sendable {
  case invalidCatalog
  case unknownProduct(productID: String)
  case failedVerification
  case storeUnavailable(debugDescription: String)
}

extension SubscriptionError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .invalidCatalog:
      return String(localized: "Premium product identifiers must belong to the catalog.")
    case .unknownProduct:
      return String(localized: "This product is unavailable. Try again later.")
    case .failedVerification:
      return String(localized: "The App Store transaction could not be verified.")
    case .storeUnavailable:
      return String(localized: "The App Store is unavailable. Try again later.")
    }
  }
}

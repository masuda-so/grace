import Foundation

/// Product identifiers and entitlement rules for the application's paid plans.
nonisolated struct SubscriptionCatalog: Equatable, Sendable {
  let productIDs: Set<String>
  let premiumProductIDs: Set<String>
  let nonRenewingDurations: [String: TimeInterval]

  private init(
    productIDs: Set<String>,
    premiumProductIDs: Set<String>,
    nonRenewingDurations: [String: TimeInterval]
  ) {
    self.productIDs = productIDs
    self.premiumProductIDs = premiumProductIDs
    self.nonRenewingDurations = nonRenewingDurations
  }

  /// A catalog with no purchasable products.
  static let empty = SubscriptionCatalog(
    productIDs: [],
    premiumProductIDs: [],
    nonRenewingDurations: [:]
  )

  /// Creates a catalog after validating every premium and nonrenewing identifier.
  static func make(
    productIDs: Set<String>,
    premiumProductIDs: Set<String>,
    nonRenewingDurations: [String: TimeInterval] = [:]
  ) throws -> SubscriptionCatalog {
    guard premiumProductIDs.isSubset(of: productIDs),
      Set(nonRenewingDurations.keys).isSubset(of: productIDs),
      nonRenewingDurations.values.allSatisfy({ $0 > 0 })
    else {
      throw SubscriptionError.invalidCatalog
    }
    return SubscriptionCatalog(
      productIDs: productIDs,
      premiumProductIDs: premiumProductIDs,
      nonRenewingDurations: nonRenewingDurations
    )
  }

  /// Returns the locally calculated expiration date for a nonrenewing product.
  func expirationDate(for productID: String, purchasedAt: Date) -> Date? {
    nonRenewingDurations[productID].map { purchasedAt.addingTimeInterval($0) }
  }

  /// Returns a nonrenewing expiration only while it is later than the supplied wall clock.
  func activeExpirationDate(
    for productID: String,
    purchasedAt: Date,
    at currentDate: Date
  ) -> Date? {
    guard
      let expirationDate = expirationDate(
        for: productID,
        purchasedAt: purchasedAt
      ), expirationDate > currentDate
    else {
      return nil
    }
    return expirationDate
  }
}

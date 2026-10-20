/// Stable StoreKit identifiers, following Apple's enum-backed product ID pattern.
enum ProductID: String {
  case subscriptionDaily = "llc.ether.grace.pro.daily"
  case subscriptionMonthly = "llc.ether.grace.pro.monthly"
  case subscriptionYearly = "llc.ether.grace.pro.yearly"
}

// Organize product IDs into groups, for convenient use elsewhere in the code.
extension ProductID {
  nonisolated static let nonRenewables = [
    ProductID.subscriptionDaily.rawValue
  ]
  nonisolated static let subscriptions = [
    ProductID.subscriptionMonthly.rawValue,
    ProductID.subscriptionYearly.rawValue,
  ]
  nonisolated static let all = nonRenewables + subscriptions
}

/// Defines the StoreKit products and access durations sold by Grace.
enum GraceCommerceCatalog {
  nonisolated static let dailyPassProductID = ProductID.subscriptionDaily.rawValue
  nonisolated static let monthlyProductID = ProductID.subscriptionMonthly.rawValue
  nonisolated static let yearlyProductID = ProductID.subscriptionYearly.rawValue

  nonisolated static let catalog: SubscriptionCatalog = {
    do {
      return try SubscriptionCatalog.make(
        productIDs: Set(ProductID.all),
        premiumProductIDs: Set(ProductID.all),
        nonRenewingDurations: [dailyPassProductID: 24 * 60 * 60]
      )
    } catch {
      assertionFailure("Invalid Grace subscription catalog: \(error)")
      return .empty
    }
  }()
}

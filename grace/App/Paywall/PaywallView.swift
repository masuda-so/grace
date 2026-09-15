import StoreKit
import SwiftUI

struct PaywallView: View {
  @Environment(AppEnvironment.self) private var environment
  @Environment(\.locale) private var locale
  @State private var isShowingSubscriptionManagement = false

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 18) {
          Image(
            systemName: environment.isPremium
              ? "checkmark.seal.fill"
              : environment.product.symbolName
          )
          .font(.system(size: 48))
          .foregroundStyle(environment.product.accent)
          .accessibilityHidden(true)

          Text(
            environment.isPremium
              ? "\(environment.product.name) Pro is active" : "\(environment.product.name) Pro"
          )
          .font(.title.bold())

          Text(environment.product.tagline)
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)

          if !environment.isAIAvailable {
            CardView {
              Label(
                "The on-device assistant is unavailable on this device or for the current language. Paid plans can’t be purchased until it becomes available.",
                systemImage: "exclamationmark.triangle"
              )
              .foregroundStyle(.secondary)
            }
          } else {
            StoreView(
              ids: ProductID.offeredProductIDs(
                dailyPassIsActive: environment.isProductActive(
                  GraceCommerceCatalog.dailyPassProductID
                )
              )
            )
            .storeButton(.hidden, for: .cancellation)
            .storeButton(.hidden, for: .restorePurchases)

            if let expirationDate = environment.entitlements.expirationDates[
              GraceCommerceCatalog.dailyPassProductID
            ], environment.isProductActive(GraceCommerceCatalog.dailyPassProductID) {
              Text(
                "Daily Pass active until \(expirationDate.formatted(date: .abbreviated, time: .shortened))"
              )
              .font(.footnote.bold())
              .foregroundStyle(environment.product.accent)
            }
          }

          RestorePurchasesButton()

          Button("Manage Subscription") {
            isShowingSubscriptionManagement = true
          }

          HStack(spacing: 16) {
            Link(
              "Privacy Policy",
              destination: environment.product.localizedLegalURL(
                environment.product.privacyPolicyURL,
                for: locale
              )
            )
            Link(
              "Terms of Use",
              destination: environment.product.localizedLegalURL(
                environment.product.termsOfUseURL,
                for: locale
              )
            )
          }
          .font(.footnote)

        }
        .padding(24)
      }
      .navigationTitle("Pro")
      .manageSubscriptionsSheet(isPresented: $isShowingSubscriptionManagement)
    }
  }

}

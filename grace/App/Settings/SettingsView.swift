import SafariServices
import StoreKit
import SwiftUI

struct SettingsView: View {
  @Environment(AppEnvironment.self) private var environment
  @Environment(\.locale) private var locale
  @State private var manageSubscriptionSheetIsPresented = false
  @State private var selectedLegalDocument: LegalDocument?

  var body: some View {
    NavigationStack {
      Form {
        Section("Product") {
          LabeledContent("App", value: environment.product.name)
          LabeledContent("Plan") {
            if environment.hasLoadedInitialState {
              Text(planName)
            } else {
              ProgressView()
                .accessibilityLabel("Checking…")
            }
          }
          LabeledContent("Version", value: version)
        }

        Section("Privacy") {
          Label(environment.product.settingsPrivacySummary, systemImage: "internaldrive")
          Label(
            "AI requests use the on-device model when available.",
            systemImage: "iphone.and.arrow.forward")
          Label("Purchases are verified with StoreKit 2.", systemImage: "checkmark.shield")
          Label(
            "This app doesn’t use analytics or a remote AI service.",
            systemImage: "hand.raised")
        }

        Section("Assistant") {
          LabeledContent("Availability", value: assistantAvailability)
        }

        Section("Purchases") {
          Button("Manage subscription") {
            manageSubscriptionSheetIsPresented = true
          }
          .manageSubscriptionsSheet(isPresented: $manageSubscriptionSheetIsPresented)

          RestorePurchasesButton()
        }

        Section("Legal") {
          legalDocumentButton(
            title: "Privacy Policy",
            systemImage: "hand.raised",
            url: environment.product.privacyPolicyURL
          )
          legalDocumentButton(
            title: "Terms of Use",
            systemImage: "doc.text",
            url: environment.product.termsOfUseURL
          )
          legalDocumentButton(
            title: "Support",
            systemImage: "questionmark.circle",
            url: environment.product.supportURL
          )
        }
      }
      .navigationTitle("Settings")
      .sheet(item: $selectedLegalDocument) { document in
        SafariDocumentView(url: document.url)
          .ignoresSafeArea()
      }
    }
  }

  private func legalDocumentButton(
    title: LocalizedStringResource,
    systemImage: String,
    url: URL
  ) -> some View {
    Button {
      selectedLegalDocument = LegalDocument(
        url: environment.product.localizedLegalURL(url, for: locale)
      )
    } label: {
      Label(title, systemImage: systemImage)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .foregroundStyle(.primary)
  }

  private var assistantAvailability: String {
    switch environment.aiAvailability {
    case .available:
      return String(localized: "Available")
    case .unavailable:
      return String(localized: "Unavailable")
    }
  }

  private var planName: LocalizedStringResource {
    environment.isPremium ? "Pro" : "Free"
  }

  private var version: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
      ?? "—"
  }
}

private struct LegalDocument: Identifiable {
  let id = UUID()
  let url: URL
}

private struct SafariDocumentView: UIViewControllerRepresentable {
  let url: URL

  func makeUIViewController(context: Context) -> SFSafariViewController {
    SFSafariViewController(url: url)
  }

  func updateUIViewController(
    _ safariViewController: SFSafariViewController,
    context: Context
  ) {}
}

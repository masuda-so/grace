import SwiftUI

/// Stable identifiers that must remain compatible with App Store records.
enum ProductIdentity {
  nonisolated static let identifier = "grace"
  nonisolated static let bundleIdentifier = "llc.ether.\(identifier)"
}

/// Product-specific presentation, assistant, and legal configuration.
struct ProductDefinition {
  let identifier: String
  let bundleIdentifier: String
  let name: String
  let tagline: String
  let symbolName: String
  let accent: Color
  let assistantInputTitle: String
  let assistantActionTitle: String
  let assistantProgressTitle: String
  let assistantTitle: String
  let assistantOutputTitle: String
  let assistantInstructions: String
  let assistantPromptPrefix: String
  let settingsPrivacySummary: String
  let privacyPolicyURL: URL
  let termsOfUseURL: URL
  let supportURL: URL

  static let grace = ProductDefinition(
    identifier: ProductIdentity.identifier,
    bundleIdentifier: ProductIdentity.bundleIdentifier,
    name: "Grace",
    tagline: String(localized: "Notice the good that is already here."),
    symbolName: "heart.text.square.fill",
    accent: .orange,
    assistantInputTitle: String(localized: "A moment you appreciated"),
    assistantActionTitle: String(localized: "Reflect"),
    assistantProgressTitle: String(localized: "Writing a reflection…"),
    assistantTitle: String(localized: "Reflection"),
    assistantOutputTitle: String(localized: "Reflection"),
    assistantInstructions:
      "You help someone reflect on gratitude. Be warm and concise. Never provide diagnosis or treatment, or encourage emotional dependence.",
    assistantPromptPrefix:
      "Offer one gentle reflection and one short follow-up question about this moment:",
    settingsPrivacySummary: String(
      localized: "Your moments and selected photos stay on this device."
    ),
    privacyPolicyURL: validatedURL(
      "https://ether-llc.com/apps/grace/privacy/"
    ),
    termsOfUseURL: validatedURL(
      "https://ether-llc.com/apps/grace/terms/"
    ),
    supportURL: validatedURL(
      "https://ether-llc.com/apps/grace/support/"
    )
  )

  func localizedLegalURL(_ url: URL, for locale: Locale) -> URL {
    guard
      locale.language.languageCode?.identifier == "ja",
      url.host == "ether-llc.com",
      !url.path.hasPrefix("/ja/")
    else {
      return url
    }

    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      return url
    }
    components.percentEncodedPath = "/ja\(components.percentEncodedPath)"
    return components.url ?? url
  }

  private static func validatedURL(_ value: String) -> URL {
    guard let url = URL(string: value) else {
      preconditionFailure("Invalid static URL: \(value)")
    }
    return url
  }
}

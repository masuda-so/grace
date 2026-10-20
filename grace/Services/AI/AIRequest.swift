import Foundation

/// The instructions, prompt, and locale for one model request.
nonisolated struct AIRequest: Codable, Equatable, Sendable {
  let instructions: String?
  let prompt: String
  let localeIdentifier: String?

  init(
    instructions: String? = nil,
    prompt: String,
    localeIdentifier: String? = nil
  ) {
    self.instructions = instructions
    self.prompt = prompt
    self.localeIdentifier = localeIdentifier
  }
}

/// Text returned by the on-device model.
nonisolated struct AIResponse: Codable, Equatable, Sendable {
  let text: String
}

/// A reason the on-device model can't accept requests.
nonisolated enum AIUnavailableReason: String, Codable, CaseIterable, Equatable, Sendable {
  case unsupportedOS
  case unsupportedLocale
  case deviceNotEligible
  case appleIntelligenceDisabled
  case modelNotReady
  case unknown

  /// A localized explanation suitable for presentation in the interface.
  var localizedDescription: String {
    switch self {
    case .unsupportedOS:
      return String(localized: "This operating system version doesn’t support the on-device model.")
    case .unsupportedLocale:
      return String(localized: "The on-device model doesn’t support the current language.")
    case .deviceNotEligible:
      return String(localized: "This device doesn’t support the on-device model.")
    case .appleIntelligenceDisabled:
      return String(localized: "Apple Intelligence is turned off.")
    case .modelNotReady:
      return String(localized: "The on-device model isn’t ready yet.")
    case .unknown:
      return String(localized: "The on-device model is unavailable.")
    }
  }
}

/// The current availability of the on-device model.
nonisolated enum AIAvailability: Equatable, Sendable {
  case available
  case unavailable(AIUnavailableReason)
}

/// An error that the assistant can explain without exposing framework details.
nonisolated enum AIError: Error, Equatable, Sendable {
  case unavailable(AIUnavailableReason)
  case emptyPrompt
  case contextWindowExceeded
  case requestInProgress
  case requestRefused
  case safetyGuardrail
  case unsupportedLanguage
  case rateLimited
  case requestTimedOut
  case generationFailed(debugDescription: String)
  case cancelled
}

extension AIError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .unavailable(let reason):
      return reason.localizedDescription
    case .emptyPrompt:
      return String(localized: "Enter a prompt before generating a response.")
    case .contextWindowExceeded:
      return String(localized: "The request is too long. Shorten it and try again.")
    case .requestInProgress:
      return String(localized: "Another request is still running. Please wait a moment.")
    case .requestRefused:
      return String(
        localized:
          "This request couldn’t be completed. Try rephrasing it for this assistant’s purpose."
      )
    case .safetyGuardrail:
      return String(
        localized:
          "This feature isn’t designed to handle that kind of input. Try a different request."
      )
    case .unsupportedLanguage:
      return String(localized: "The on-device model doesn’t support a language in this request.")
    case .rateLimited:
      return String(localized: "The on-device model is busy. Please try again shortly.")
    case .requestTimedOut:
      return String(localized: "The on-device model took too long to respond. Please try again.")
    case .generationFailed:
      return String(localized: "The on-device model couldn’t generate a response. Try again.")
    case .cancelled:
      return String(localized: "AI generation was cancelled.")
    }
  }
}

import Foundation

/// An AI client used on unsupported systems and in deterministic previews.
nonisolated struct UnavailableAIClient: AIClient {
  let reason: AIUnavailableReason

  init(reason: AIUnavailableReason) {
    self.reason = reason
  }

  var availability: AIAvailability {
    get async {
      .unavailable(reason)
    }
  }

  func respond(to request: AIRequest) async throws -> AIResponse {
    guard !request.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      throw AIError.emptyPrompt
    }
    throw AIError.unavailable(reason)
  }
}

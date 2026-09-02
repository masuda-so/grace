import Foundation

/// Generates product-specific text with the best model available on the device.
nonisolated protocol AIClient: Sendable {
  /// Returns the model's current availability.
  var availability: AIAvailability { get async }

  /// Responds to a validated request.
  func respond(to request: AIRequest) async throws -> AIResponse

  /// Generates a typed, editable moment candidate from the current conversation.
  func generateMomentDraft(from request: AIRequest) async throws -> AssistantMomentDraft

  /// Releases model state for a conversation that the person has ended.
  func resetConversation(_ conversationIdentifier: UUID) async
}

extension AIClient {
  func generateMomentDraft(from request: AIRequest) async throws -> AssistantMomentDraft {
    throw AIError.generationFailed(
      debugDescription: "This AI client does not implement guided moment generation."
    )
  }

  func resetConversation(_ conversationIdentifier: UUID) async {}
}

/// Creates the AI client used by the application.
nonisolated enum AIClientFactory {
  /// Creates an on-device client when Foundation Models is available.
  static func makeDefault() -> any AIClient {
    #if canImport(FoundationModels)
      if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
        return FoundationModelAIClient()
      }
    #endif
    return UnavailableAIClient(reason: .unsupportedOS)
  }
}

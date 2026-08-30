#if canImport(FoundationModels)
  import Foundation
  import FoundationModels

  /// Sends requests to Apple's on-device system language model.
  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  nonisolated struct FoundationModelAIClient: AIClient {
    private let model: SystemLanguageModel

    init(model: SystemLanguageModel = .default) {
      self.model = model
    }

    var availability: AIAvailability {
      get async {
        guard model.supportsLocale() else {
          return .unavailable(.unsupportedLocale)
        }

        switch model.availability {
        case .available:
          return .available
        case .unavailable(let reason):
          switch reason {
          case .deviceNotEligible:
            return .unavailable(.deviceNotEligible)
          case .appleIntelligenceNotEnabled:
            return .unavailable(.appleIntelligenceDisabled)
          case .modelNotReady:
            return .unavailable(.modelNotReady)
          @unknown default:
            return .unavailable(.unknown)
          }
        }
      }
    }

    func respond(to request: AIRequest) async throws -> AIResponse {
      let promptText = request.prompt.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !promptText.isEmpty else {
        throw AIError.emptyPrompt
      }

      if let localeIdentifier = request.localeIdentifier {
        let locale = Locale(identifier: localeIdentifier)
        guard model.supportsLocale(locale) else {
          throw AIError.unavailable(.unsupportedLocale)
        }
      }

      let currentAvailability = await availability
      guard case .available = currentAvailability else {
        if case .unavailable(let reason) = currentAvailability {
          throw AIError.unavailable(reason)
        }
        throw AIError.unavailable(.unknown)
      }

      do {
        let session = LanguageModelSession(
          model: model,
          instructions: request.instructions
        )
        let prompt = Prompt {
          promptText
        }
        let response = try await session.respond(to: prompt)
        try Task.checkCancellation()
        return AIResponse(text: response.content)
      } catch is CancellationError {
        throw AIError.cancelled
      } catch {
        throw Self.aiError(from: error)
      }
    }

    /// Adapts Foundation Models errors to the app's stable error vocabulary.
    static func aiError(from error: any Error) -> AIError {
      #if compiler(>=6.4)
        if #available(iOS 27.0, macOS 27.0, visionOS 27.0, *) {
          if let languageModelError = error as? LanguageModelError {
            switch languageModelError {
            case .contextSizeExceeded:
              return .contextWindowExceeded
            case .rateLimited:
              return .rateLimited
            case .guardrailViolation:
              return .safetyGuardrail
            case .refusal:
              return .requestRefused
            case .unsupportedLanguageOrLocale:
              return .unsupportedLanguage
            case .timeout:
              return .requestTimedOut
            case .unsupportedCapability,
              .unsupportedTranscriptContent,
              .unsupportedGenerationGuide:
              return .generationFailed(debugDescription: languageModelError.debugDescription)
            @unknown default:
              return .generationFailed(debugDescription: languageModelError.debugDescription)
            }
          }

          if let systemLanguageModelError = error as? SystemLanguageModel.Error {
            switch systemLanguageModelError {
            case .assetsUnavailable:
              return .unavailable(.modelNotReady)
            @unknown default:
              return .generationFailed(debugDescription: systemLanguageModelError.debugDescription)
            }
          }

          if let sessionError = error as? LanguageModelSession.Error {
            switch sessionError {
            case .concurrentRequests:
              return .requestInProgress
            case .transcriptMutationWhileResponding:
              return .generationFailed(debugDescription: sessionError.debugDescription)
            @unknown default:
              return .generationFailed(debugDescription: sessionError.debugDescription)
            }
          }
        }
      #endif

      return .generationFailed(debugDescription: String(describing: error))
    }
  }
#endif

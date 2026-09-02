#if canImport(FoundationModels)
  import Foundation
  import FoundationModels

  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  @Generable(description: "An editable gratitude-journal Moment candidate for human review")
  private struct GeneratedMomentDraft {
    @Guide(description: "A concise, meaningful title. It must not be empty.")
    var title: String

    @Guide(description: "An optional supporting note. Use an empty string when no note is needed.")
    var note: String

    @Guide(
      description:
        "The Moment date and time in RFC 3339 format, including a numeric UTC offset or Z."
    )
    var timestampRFC3339: String
  }

  /// Sends requests to Apple's on-device system language model.
  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  actor FoundationModelAIClient: AIClient {
    private struct SessionState {
      let session: LanguageModelSession
      var estimatedCharacterUsage: Int
    }

    private static let contextSafetyMargin = 128
    private static let textResponseTokenLimit = 384
    private static let draftResponseTokenLimit = 256

    private let model: SystemLanguageModel
    private var sessions: [UUID: SessionState] = [:]

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
      do {
        let (promptText, session) = try await preparedRequest(
          request,
          responseTokenLimit: Self.textResponseTokenLimit
        )
        let prompt = Prompt {
          promptText
        }
        let response = try await session.respond(
          to: prompt,
          options: GenerationOptions(maximumResponseTokens: Self.textResponseTokenLimit)
        )
        recordEstimatedUsage(
          for: request.conversationIdentifier,
          prompt: promptText,
          responseCharacterCount: response.content.count
        )
        try Task.checkCancellation()
        return AIResponse(text: response.content)
      } catch is CancellationError {
        throw AIError.cancelled
      } catch let error as AIError {
        throw error
      } catch {
        throw Self.aiError(from: error)
      }
    }

    func generateMomentDraft(from request: AIRequest) async throws -> AssistantMomentDraft {
      do {
        let (promptText, session) = try await preparedRequest(
          request,
          schema: GeneratedMomentDraft.generationSchema,
          responseTokenLimit: Self.draftResponseTokenLimit
        )
        let response = try await session.respond(
          to: Prompt { promptText },
          generating: GeneratedMomentDraft.self,
          options: GenerationOptions(maximumResponseTokens: Self.draftResponseTokenLimit)
        )
        recordEstimatedUsage(
          for: request.conversationIdentifier,
          prompt: promptText,
          responseCharacterCount: response.content.title.count
            + response.content.note.count
            + response.content.timestampRFC3339.count
        )
        try Task.checkCancellation()
        return try AssistantMomentDraft.generated(
          title: response.content.title,
          note: response.content.note,
          timestampRFC3339: response.content.timestampRFC3339
        )
      } catch is CancellationError {
        throw AIError.cancelled
      } catch let error as AIError {
        throw error
      } catch {
        throw Self.aiError(from: error)
      }
    }

    func resetConversation(_ conversationIdentifier: UUID) {
      sessions[conversationIdentifier] = nil
    }

    private func preparedRequest(
      _ request: AIRequest,
      schema: GenerationSchema? = nil,
      responseTokenLimit: Int
    ) async throws -> (String, LanguageModelSession) {
      guard !request.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
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

      let state: SessionState
      let promptCandidates: [String]
      let createdNewSession: Bool
      if let existingState = sessions[request.conversationIdentifier] {
        state = existingState
        promptCandidates = [request.continuationPrompt ?? request.prompt]
        createdNewSession = false
      } else {
        let session = LanguageModelSession(
          model: model,
          instructions: request.instructions
        )
        state = SessionState(
          session: session,
          estimatedCharacterUsage: request.instructions?.count ?? 0
        )
        sessions[request.conversationIdentifier] = state
        promptCandidates = request.newSessionPromptCandidates
        createdNewSession = true
      }

      do {
        let promptText = try await firstPromptThatFits(
          promptCandidates,
          state: state,
          schema: schema,
          responseTokenLimit: responseTokenLimit
        )
        return (promptText, state.session)
      } catch {
        if createdNewSession {
          sessions[request.conversationIdentifier] = nil
        }
        throw error
      }
    }

    private func firstPromptThatFits(
      _ promptCandidates: [String],
      state: SessionState,
      schema: GenerationSchema?,
      responseTokenLimit: Int
    ) async throws -> String {
      let candidates = promptCandidates.map {
        $0.trimmingCharacters(in: .whitespacesAndNewlines)
      }.filter { !$0.isEmpty }
      guard !candidates.isEmpty else { throw AIError.emptyPrompt }

      let reservedTokens = responseTokenLimit + Self.contextSafetyMargin
      if #available(iOS 26.4, macOS 26.4, visionOS 26.4, *) {
        let transcriptTokenCount = try await model.tokenCount(for: state.session.transcript)
        let schemaTokenCount: Int
        if let schema {
          schemaTokenCount = try await model.tokenCount(for: schema)
        } else {
          schemaTokenCount = 0
        }
        let availablePromptTokens =
          model.contextSize - transcriptTokenCount - schemaTokenCount - reservedTokens

        for candidate in candidates {
          let promptTokenCount = try await model.tokenCount(for: Prompt { candidate })
          if promptTokenCount <= availablePromptTokens {
            return candidate
          }
        }
      } else {
        // Before tokenCount(for:) became available, one Character per token is a
        // deliberately conservative bound for Japanese and other dense scripts.
        let availableCharacters =
          model.contextSize - state.estimatedCharacterUsage - reservedTokens
        if let candidate = candidates.first(where: { $0.count <= availableCharacters }) {
          return candidate
        }
      }

      throw AIError.contextWindowExceeded
    }

    private func recordEstimatedUsage(
      for conversationIdentifier: UUID,
      prompt: String,
      responseCharacterCount: Int
    ) {
      guard var state = sessions[conversationIdentifier] else { return }
      state.estimatedCharacterUsage += prompt.count + responseCharacterCount
      sessions[conversationIdentifier] = state
    }

    /// Adapts Foundation Models errors to the app's stable error vocabulary.
    static func aiError(from error: any Error) -> AIError {
      #if compiler(<6.4)
        if let generationError = error as? LanguageModelSession.GenerationError {
          return aiError(from: generationError)
        }
      #else
        if #unavailable(iOS 27.0, macOS 27.0, visionOS 27.0) {
          if let generationError = error as? LanguageModelSession.GenerationError {
            return aiError(from: generationError)
          }
        }
      #endif

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

    /// Maps the GenerationError vocabulary shipped with the stable iOS 26 SDK.
    private static func aiError(
      from error: LanguageModelSession.GenerationError
    ) -> AIError {
      switch error {
      case .exceededContextWindowSize:
        return .contextWindowExceeded
      case .assetsUnavailable:
        return .unavailable(.modelNotReady)
      case .guardrailViolation:
        return .safetyGuardrail
      case .unsupportedLanguageOrLocale:
        return .unsupportedLanguage
      case .rateLimited:
        return .rateLimited
      case .concurrentRequests:
        return .requestInProgress
      case .refusal:
        return .requestRefused
      case .unsupportedGuide(let context), .decodingFailure(let context):
        return .generationFailed(debugDescription: context.debugDescription)
      @unknown default:
        return .generationFailed(debugDescription: String(describing: error))
      }
    }
  }
#endif

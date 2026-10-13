import SwiftUI

struct AssistantView: View {
  @Environment(AppEnvironment.self) private var environment
  @Binding var selection: AppSection
  @State private var text = ""
  @State private var generationTask: Task<Void, Never>?

  var body: some View {
    NavigationStack {
      Group {
        switch environment.aiAvailability {
        case .available:
          if environment.isPremium {
            assistantForm
          } else {
            lockedView
          }
        case .unavailable(.appleIntelligenceDisabled):
          unavailableView(
            message: String(
              localized: "The assistant is unavailable because Apple Intelligence isn’t turned on."
            )
          )
        case .unavailable(.modelNotReady):
          unavailableView(
            message: String(localized: "The assistant isn’t ready yet. Try again later.")
          )
        case .unavailable(let reason):
          unavailableView(message: reason.localizedDescription)
        }
      }
      .navigationTitle(environment.product.assistantTitle)
      .onDisappear {
        generationTask?.cancel()
        generationTask = nil
      }
    }
  }

  private var assistantForm: some View {
    Form {
      Section(environment.product.assistantInputTitle) {
        TextEditor(text: $text)
          .frame(minHeight: 130)
          .accessibilityLabel(environment.product.assistantInputTitle)
          .disabled(environment.isGenerating)
      }

      Section {
        if environment.isGenerating {
          HStack {
            ProgressView()
            Text(environment.product.assistantProgressTitle)
            Spacer()
            Button("Stop", role: .cancel) {
              generationTask?.cancel()
            }
          }
        } else {
          Button {
            startGeneration()
          } label: {
            Label(environment.product.assistantActionTitle, systemImage: "sparkles")
              .frame(maxWidth: .infinity)
          }
          .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      } footer: {
        Text(availabilityMessage)
      }

      if let errorMessage = environment.assistantErrorMessage {
        Section("Couldn’t Generate") {
          Text(errorMessage)
            .foregroundStyle(.secondary)
        }
      }

      if let response = environment.assistantResponse {
        Section {
          Text(response)
            .textSelection(.enabled)
        } header: {
          Text(environment.product.assistantOutputTitle)
        } footer: {
          Text(
            "Generated on this device with Apple Foundation Models. AI output may be inaccurate; review it before use."
          )
        }
      }
    }
  }

  private func startGeneration() {
    let requestText = text
    generationTask?.cancel()
    generationTask = Task {
      await environment.requestAssistantResponse(for: requestText)
      generationTask = nil
    }
  }

  private var lockedView: some View {
    ContentUnavailableView {
      Label(
        "\(environment.product.assistantTitle) is a Pro feature",
        systemImage: "crown.fill"
      )
    } description: {
      Text(
        "Choose the non-renewing Daily Pass or an auto-renewing plan to use the on-device assistant."
      )
    } actions: {
      Button("View Pro options") {
        selection = .pro
      }
      .buttonStyle(.borderedProminent)
      .tint(environment.product.accent)
    }
  }

  private func unavailableView(message: String) -> some View {
    ContentUnavailableView {
      Label(environment.product.assistantTitle, systemImage: "apple.intelligence")
    } description: {
      Text(message)
    }
  }

  private var availabilityMessage: String {
    switch environment.aiAvailability {
    case .available:
      return String(localized: "Processed on this device with Apple Foundation Models.")
    case .unavailable(let reason):
      return String(
        localized:
          "\(reason.localizedDescription) \(environment.product.name) remains usable without the assistant."
      )
    }
  }
}

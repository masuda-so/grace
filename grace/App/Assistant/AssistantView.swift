import Foundation
import SwiftData
import SwiftUI

struct AssistantView: View {
  @Environment(AppEnvironment.self) private var environment
  @Environment(\.calendar) private var calendar
  @Environment(\.locale) private var locale
  @Environment(\.timeZone) private var timeZone
  @Binding var selection: AppSection
  @Query(sort: \Moment.timestamp, order: .reverse)
  private var moments: [Moment]
  @State private var text = ""
  @State private var generationTask: Task<Void, Never>?
  @State private var draftForReview: AssistantMomentDraft?

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
      .toolbar {
        if environment.isPremium, !environment.assistantMessages.isEmpty {
          ToolbarItem(placement: .primaryAction) {
            Button("New Conversation", systemImage: "square.and.pencil") {
              environment.resetAssistantConversation()
              text = ""
              draftForReview = nil
            }
            .disabled(environment.isGenerating)
          }
        }
      }
      .sheet(item: $draftForReview) { draft in
        AssistantMomentReviewView(draft: draft)
      }
      .onDisappear {
        generationTask?.cancel()
        generationTask = nil
      }
    }
  }

  private var assistantForm: some View {
    Form {
      Section {
        if environment.assistantMessages.isEmpty {
          ContentUnavailableView {
            Label("Start a Conversation", systemImage: "sparkles")
          } description: {
            Text(
              "Share what you appreciate, ask about a recent moment, or talk through a new entry."
            )
          }
        } else {
          ForEach(environment.assistantMessages) { message in
            AssistantMessageView(message: message, assistantName: environment.product.name)
          }
        }
      } header: {
        Text("Conversation")
      } footer: {
        Text(
          "Recent moment titles, notes, and exact dates may be used on device. Photos are never included. AI output may be inaccurate."
        )
      }

      Section(environment.product.assistantInputTitle) {
        TextEditor(text: $text)
          .frame(minHeight: 100)
          .accessibilityLabel(environment.product.assistantInputTitle)
          .disabled(environment.isGenerating)
      }

      Section {
        if environment.isGenerating {
          HStack {
            ProgressView()
            Text(
              environment.isPreparingMomentDraft
                ? String(localized: "Preparing a moment candidate…")
                : environment.product.assistantProgressTitle
            )
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

          if environment.assistantMessages.contains(where: { $0.role == .person }) {
            Button {
              prepareMomentDraft()
            } label: {
              Label("Prepare Moment Candidate", systemImage: "square.and.pencil")
                .frame(maxWidth: .infinity)
            }
          }
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
    }
  }

  private func startGeneration() {
    let requestText = text
    let context = conversationContext
    text = ""
    generationTask?.cancel()
    generationTask = Task {
      await environment.requestAssistantResponse(for: requestText, context: context)
      generationTask = nil
    }
  }

  private func prepareMomentDraft() {
    let context = conversationContext
    generationTask?.cancel()
    generationTask = Task {
      draftForReview = await environment.requestAssistantMomentDraft(context: context)
      generationTask = nil
    }
  }

  private var conversationContext: AssistantConversationContext {
    let records = moments.map {
      AssistantMomentRecord(
        title: $0.title,
        note: $0.note,
        timestamp: $0.timestamp
      )
    }
    return environment.makeAssistantConversationContext(
      recentMoments: records,
      locale: locale,
      timeZone: timeZone,
      calendar: calendar
    )
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

      Button("Open Moments") {
        selection = .moments
      }
    }
  }

  private func unavailableView(message: String) -> some View {
    ContentUnavailableView {
      Label(environment.product.assistantTitle, systemImage: "apple.intelligence")
    } description: {
      Text(message)
      Text("Your journal remains available without the assistant.")
    } actions: {
      Button("Open Moments") {
        selection = .moments
      }
      .buttonStyle(.borderedProminent)
      .tint(environment.product.accent)
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

private struct AssistantMessageView: View {
  let message: AssistantMessage
  let assistantName: String

  var body: some View {
    HStack {
      if message.role == .person {
        Spacer(minLength: 32)
      }

      VStack(alignment: message.role == .person ? .trailing : .leading, spacing: 4) {
        Text(message.role == .person ? String(localized: "You") : assistantName)
          .font(.caption.weight(.semibold))
          .foregroundStyle(.secondary)
        Text(message.text)
          .textSelection(.enabled)
      }
      .padding(12)
      .background(
        message.role == .person ? Color.accentColor.opacity(0.14) : Color.secondary.opacity(0.1),
        in: RoundedRectangle(cornerRadius: 14)
      )

      if message.role == .assistant {
        Spacer(minLength: 32)
      }
    }
    .accessibilityElement(children: .combine)
  }
}

struct AssistantMomentReviewView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(DataContainer.self) private var dataContainer
  @State private var title: String
  @State private var note: String
  @State private var timestamp: Date
  @State private var showsSaveError = false
  private let draftIdentifier: UUID

  init(draft: AssistantMomentDraft) {
    draftIdentifier = draft.id
    _title = State(initialValue: draft.title)
    _note = State(initialValue: draft.note)
    _timestamp = State(initialValue: draft.timestamp)
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("Title (Required)", text: $title)
          TextField("Log your small wins", text: $note, axis: .vertical)
            .lineLimit(3...8)
          DatePicker(
            "Date and Time",
            selection: $timestamp,
            displayedComponents: [.date, .hourAndMinute]
          )
        } header: {
          Text("Moment Candidate")
        } footer: {
          Text("Review and edit every field before saving this moment.")
        }

        Section {
          Label("No photo will be added to this candidate.", systemImage: "photo.badge.checkmark")
        } footer: {
          Text("Nothing is saved until you choose Save Moment.")
        }
      }
      .navigationTitle("Review Moment")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", role: .cancel) {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save Moment", systemImage: "checkmark") {
            saveMoment()
          }
          .disabled(validatedDraft == nil)
        }
      }
      .alert("Save Failed", isPresented: $showsSaveError) {
        Button("OK") {}
      } message: {
        Text("Your moment could not be saved. Please try again.")
      }
    }
  }

  private var validatedDraft: AssistantMomentDraft? {
    AssistantMomentDraft.validated(
      id: draftIdentifier,
      title: title,
      note: note,
      timestamp: timestamp
    )
  }

  private func saveMoment() {
    guard let draft = validatedDraft else { return }
    do {
      try AssistantMomentSaver.save(draft, in: dataContainer)
      dismiss()
    } catch {
      showsSaveError = true
    }
  }
}

@MainActor
enum AssistantMomentSaver {
  static func save(_ draft: AssistantMomentDraft, in dataContainer: DataContainer) throws {
    let moment = Moment(
      title: draft.title,
      note: draft.note,
      imageData: nil,
      timestamp: draft.timestamp
    )
    try dataContainer.context.performTransactionOrRollback {
      dataContainer.context.insert(moment)
      try dataContainer.badgeManager.unlockBadges(newMoment: moment)
    }
  }
}

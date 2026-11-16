import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct MomentEntryView: View {
  @State private var title = ""
  @State private var note = ""
  @State private var photoSelection = PhotoSelection()
  @State private var isShowingCancelConfirmation = false
  @State private var alert: EntryAlert?

  @Environment(\.dismiss) private var dismiss
  @Environment(DataContainer.self) private var dataContainer

  var body: some View {
    NavigationStack {
      ScrollView {
        contentStack
      }
      .scrollDismissesKeyboard(.interactively)
      .navigationTitle("Grateful For")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", systemImage: "xmark") {
            if !hasUnsavedChanges {
              dismiss()
            } else {
              isShowingCancelConfirmation = true
            }
          }
          .confirmationDialog(
            "Discard Moment",
            isPresented: $isShowingCancelConfirmation
          ) {
            Button("Discard Moment", role: .destructive) {
              dismiss()
            }
          }
        }

        ToolbarItem(placement: .confirmationAction) {
          Button("Add", systemImage: "checkmark") {
            let newMoment = Moment(
              title: title,
              note: note,
              imageData: imageData,
              timestamp: .now
            )
            do {
              try dataContainer.context.performTransactionOrRollback {
                dataContainer.context.insert(newMoment)
                try dataContainer.badgeManager.unlockBadges(newMoment: newMoment)
              }
              dismiss()
            } catch {
              alert = EntryAlert(
                title: "Save Failed",
                message: "Your moment could not be saved. Please try again."
              )
            }
          }
          .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoadingPhoto)
        }
      }
      .alert(item: $alert) { alert in
        Alert(
          title: Text(alert.title),
          message: Text(alert.message),
          dismissButton: .default(Text("OK"))
        )
      }
    }
    .interactiveDismissDisabled(hasUnsavedChanges)
  }

  private var hasUnsavedChanges: Bool {
    !title.isEmpty || !note.isEmpty || photoSelection.imageSelection != nil
  }

  private var isLoadingPhoto: Bool {
    if case .loading = photoSelection.imageState { return true }
    return false
  }

  private var photoPicker: some View {
    @Bindable var photoSelection = photoSelection

    return VStack(alignment: .leading, spacing: 12) {
      PhotoSelectionImage(imageState: photoSelection.imageState)
      if case .failure = photoSelection.imageState {
        Text("The photo could not be loaded. Please choose it again.")
          .foregroundStyle(.secondary)
      }
      PhotosPicker(
        selection: $photoSelection.imageSelection,
        matching: .images,
        photoLibrary: .shared()
      ) {
        Label("Choose Photo", systemImage: "photo.badge.plus")
      }
      .accessibilityHint("Select a photo to include with this moment.")
    }
  }

  var contentStack: some View {
    VStack(alignment: .leading, spacing: 20) {
      VStack(alignment: .leading, spacing: 8) {
        Text("Title (Required)").font(.headline)
        TextField("Title (Required)", text: $title, axis: .vertical)
          .font(.title2)
          .accessibilityIdentifier("moment-title")
      }
      Divider()
      VStack(alignment: .leading, spacing: 8) {
        Text("Note (Optional)").font(.headline)
        TextField("Log your small wins", text: $note, axis: .vertical)
          .lineLimit(3...Int.max)
          .accessibilityIdentifier("moment-note")
      }
      Divider()
      VStack(alignment: .leading, spacing: 8) {
        Text("Photo (Optional)").font(.headline)
        photoPicker
      }
    }
    .padding()
  }

  private var imageData: Data? {
    guard case .success(let data) = photoSelection.imageState else {
      return nil
    }
    return data
  }
}

private struct PhotoSelectionImage: View {
  let imageState: PhotoSelection.ImageState

  var body: some View {
    Group {
      switch imageState {
      case .success(let imageData):
        if let uiImage = UIImage(data: imageData) {
          Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
        }
      case .loading(let progress):
        ProgressView(progress)
          .frame(height: 250)
          .frame(maxWidth: .infinity)
      case .empty:
        EmptyView()
      case .failure:
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.largeTitle)
          .foregroundStyle(.secondary)
      }
    }
    .accessibilityHidden(true)
  }
}

private struct EntryAlert: Identifiable {
  let id = UUID()
  let title: LocalizedStringResource
  let message: LocalizedStringResource
}

#Preview {
  MomentEntryView()
    .sampleDataContainer()
}

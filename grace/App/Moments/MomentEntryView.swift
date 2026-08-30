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
            if title.isEmpty, note.isEmpty, imageData == nil {
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
          .disabled(title.isEmpty)
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
  }

  private var photoPicker: some View {
    @Bindable var photoSelection = photoSelection

    return ZStack {
      PhotoSelectionImage(imageState: photoSelection.imageState)

      PhotosPicker(
        selection: $photoSelection.imageSelection,
        matching: .images,
        photoLibrary: .shared()
      ) {
        Color.clear
          .contentShape(Rectangle())
      }
      .accessibilityLabel("Choose Photo")
      .accessibilityHint("Select a photo to include with this moment.")
    }
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }

  var contentStack: some View {
    VStack(alignment: .leading) {
      TextField(text: $title) {
        Text("Title (Required)")
      }
      .font(.title.bold())
      .padding(.top, 48)
      Divider()

      TextField("Log your small wins", text: $note, axis: .vertical)
        .multilineTextAlignment(.leading)
        .lineLimit(5...Int.max)

      photoPicker
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
        Image(systemName: "photo.badge.plus.fill")
          .font(.largeTitle)
          .frame(height: 250)
          .frame(maxWidth: .infinity)
          .background(Color(white: 0.4, opacity: 0.32))
      case .failure:
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.largeTitle)
          .frame(height: 250)
          .frame(maxWidth: .infinity)
          .background(Color(white: 0.4, opacity: 0.32))
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

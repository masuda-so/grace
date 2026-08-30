import OSLog
import SwiftData
import SwiftUI

struct MomentDetailView: View {
  private static let logger = Logger(subsystem: "llc.ether.grace", category: "Moments")

  var moment: Moment
  @State private var showConfirmation = false
  @State private var deletionError: String?

  @Environment(\.dismiss) private var dismiss
  @Environment(DataContainer.self) private var dataContainer

  var body: some View {
    ScrollView {
      contentStack
    }
    .navigationTitle(moment.title)
    .toolbar {
      ToolbarItem(placement: .destructiveAction) {
        Button {
          showConfirmation = true
        } label: {
          Image(systemName: "trash")
        }
        .confirmationDialog("Delete Moment", isPresented: $showConfirmation) {
          Button("Delete Moment", role: .destructive) {
            deleteMoment()
          }
        } message: {
          Text("The moment will be permanently deleted. Earned badges won't be removed.")
        }
      }
    }
    .alert("Delete Failed", isPresented: isShowingDeletionError) {
      Button("OK", role: .cancel) {
        deletionError = nil
      }
    } message: {
      Text(deletionError ?? String(localized: "Please try again."))
    }
  }

  private var contentStack: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(moment.timestamp, style: .date)
          .font(.subheadline)
        Spacer()
        ForEach(moment.badges) { badge in
          NavigationLink {
            BadgeDetailView(badge: badge)
          } label: {
            Image(badge.details.image)
              .resizable()
              .frame(width: 44, height: 44)
              .accessibilityLabel(Text(badge.details.title))
          }
        }
      }
      if !moment.note.isEmpty {
        Text(moment.note)
          .textSelection(.enabled)
      }
      if let image = moment.image {
        Image(uiImage: image)
          .resizable()
          .scaledToFit()
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .accessibilityLabel(Text("Photo for \(moment.title)"))
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
  }

  private var isShowingDeletionError: Binding<Bool> {
    Binding(
      get: { deletionError != nil },
      set: { isPresented in
        if !isPresented {
          deletionError = nil
        }
      }
    )
  }

  /// Local persistence boundary: the tutorial's delete/save/dismiss sequence is
  /// retained, with rollback and user-visible failure reporting added around it.
  private func deleteMoment() {
    do {
      try dataContainer.context.performTransactionOrRollback {
        dataContainer.context.delete(moment)
      }
      dismiss()
    } catch {
      Self.logger.error(
        "Could not delete a moment: \(String(describing: error), privacy: .private)"
      )
      deletionError = String(
        localized: "Your moment could not be deleted. Please try again."
      )
    }
  }
}

#Preview {
  NavigationStack {
    MomentDetailView(moment: .imageSample)
      .sampleDataContainer()
  }
}

#Preview("Long note") {
  NavigationStack {
    MomentDetailView(moment: Moment.longTextSample)
      .sampleDataContainer()
  }
}

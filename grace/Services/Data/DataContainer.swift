import Observation
import SwiftData
import SwiftUI

/// Owns Grace's SwiftData container and achievement services.
@MainActor
@Observable
final class DataContainer {
  let modelContainer: ModelContainer
  let badgeManager: BadgeManager

  var context: ModelContext {
    modelContainer.mainContext
  }

  init(
    isStoredInMemoryOnly: Bool = false,
    includesSampleMoments: Bool = false
  ) {
    let schema = Schema([Moment.self, Badge.self])
    let configuration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: isStoredInMemoryOnly
    )

    do {
      let modelContainer = try ModelContainer(
        for: schema,
        configurations: [configuration]
      )
      self.modelContainer = modelContainer
      badgeManager = BadgeManager(modelContainer: modelContainer)
      try badgeManager.loadBadgesIfNeeded()

      if includesSampleMoments {
        try context.performTransactionOrRollback {
          for sample in Moment.sampleData {
            let moment = Moment(
              title: sample.title,
              note: sample.note,
              imageData: sample.imageData,
              timestamp: sample.timestamp
            )
            context.insert(moment)
            try badgeManager.unlockBadges(newMoment: moment)
          }
        }
      }
    } catch {
      fatalError("Could not create the Grace data container: \(error)")
    }
  }
}

extension View {
  /// Supplies an in-memory SwiftData container for previews.
  @MainActor
  func sampleDataContainer() -> some View {
    let container = DataContainer(
      isStoredInMemoryOnly: true,
      includesSampleMoments: true
    )

    return environment(container)
      .modelContainer(container.modelContainer)
  }
}

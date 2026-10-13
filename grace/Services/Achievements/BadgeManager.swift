import Foundation
import SwiftData

class BadgeManager {
  private let modelContainer: ModelContainer

  init(modelContainer: ModelContainer) {
    self.modelContainer = modelContainer
  }

  func unlockBadges(newMoment: Moment) throws {
    let context = modelContainer.mainContext
    let moments = try context.fetch(FetchDescriptor<Moment>())
    let lockedBadges = try context.fetch(
      FetchDescriptor<Badge>(predicate: #Predicate { $0.timestamp == nil })
    )

    var newlyUnlocked: [Badge] = []
    for badge in lockedBadges {
      switch badge.details {
      case .firstEntry where moments.count >= 1,
        .fiveStars where moments.count >= 5,
        .shutterbug where moments.count(where: { $0.image != nil }) >= 3,
        .expressive where moments.count(where: { $0.image != nil && !$0.note.isEmpty }) >= 5,
        .perfectTen where moments.count >= 10 && lockedBadges.count == 1:
        newlyUnlocked.append(badge)
      default:
        continue
      }
    }

    for badge in newlyUnlocked {
      badge.moment = newMoment
      badge.timestamp = newMoment.timestamp
    }
  }

  func loadBadgesIfNeeded() throws {
    let context = modelContainer.mainContext
    var fetchDescriptor = FetchDescriptor<Badge>()
    fetchDescriptor.fetchLimit = 1
    let existingBadges = try context.fetch(fetchDescriptor)
    if existingBadges.isEmpty {
      for details in BadgeDetails.allCases {
        context.insert(Badge(details: details))
      }
    }
  }
}

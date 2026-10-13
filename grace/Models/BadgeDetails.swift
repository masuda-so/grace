import Foundation
import SwiftUI

enum BadgeDetails: Int, Codable, CaseIterable {
  case firstEntry
  case fiveStars
  case shutterbug
  case expressive
  case perfectTen

  var requirements: LocalizedStringResource {
    switch self {
    case .firstEntry:
      return "Log a moment to start your journey."
    case .fiveStars:
      return "Record five moments."
    case .shutterbug:
      return "Add three entries with photos."
    case .expressive:
      return "Add five moments with a photo and text."
    case .perfectTen:
      return "Record at least 10 moments, collecting all the other badges along the way."
    }
  }

  var title: LocalizedStringResource {
    switch self {
    case .firstEntry:
      return "Start the Journey"
    case .fiveStars:
      return "5 Stars"
    case .shutterbug:
      return "Shutterbug"
    case .expressive:
      return "Expressive"
    case .perfectTen:
      return "Perfect 10"
    }
  }

  var image: ImageResource {
    switch self {
    case .firstEntry:
      return .firstEntryUnlocked
    case .fiveStars:
      return .fiveStarsUnlocked
    case .shutterbug:
      return .shutterbugUnlocked
    case .expressive:
      return .expressiveUnlocked
    case .perfectTen:
      return .perfectTenUnlocked
    }
  }

  var lockedImage: ImageResource {
    switch self {
    case .firstEntry:
      return .firstEntryLocked
    case .fiveStars:
      return .fiveStarsLocked
    case .shutterbug:
      return .shutterbugLocked
    case .expressive:
      return .expressiveLocked
    case .perfectTen:
      return .perfectTenLocked
    }
  }

  var color: Color {
    switch self {
    case .firstEntry:
      return .ember
    case .fiveStars:
      return .ruby
    case .shutterbug:
      return .sapphire
    case .expressive:
      return .ocean
    case .perfectTen:
      return .ember
    }
  }

  var congratulatoryMessage: LocalizedStringResource {
    switch self {
    case .firstEntry:
      return "Every journey begins with a single step. Congratulations — you’re on your way!"
    case .fiveStars:
      return
        "You’re building momentum! The more you focus on regular practice, the better you get at choosing to keep up your intentioned habits."
    case .shutterbug:
      return
        "Photos connect us to our past, and looking at them can take us right back to the grateful feeling we had when we snapped them."
    case .expressive:
      return "Look at you, giving yourself all the ways to savor your happy memories!"
    case .perfectTen:
      return
        "You're getting the hang of your new habit! Keep it up and see how far it can take you."
    }
  }
}

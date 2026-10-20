import SwiftUI

/// The finite set of achievements supported by Grace.
enum BadgeKind: Int, Codable, CaseIterable, Hashable {
  case firstEntry
  case fiveStars
  case shutterbug
  case expressive
  case perfectTen

  var title: LocalizedStringResource {
    switch self {
    case .firstEntry: "Start the Journey"
    case .fiveStars: "Five Stars"
    case .shutterbug: "Shutterbug"
    case .expressive: "Expressive"
    case .perfectTen: "Perfect Ten"
    }
  }

  var requirements: LocalizedStringResource {
    switch self {
    case .firstEntry: "Record your first moment."
    case .fiveStars: "Record five moments."
    case .shutterbug: "Add three moments with photos."
    case .expressive: "Add five moments with both a photo and a note."
    case .perfectTen: "Record ten moments and unlock every other badge."
    }
  }

  var congratulatoryMessage: LocalizedStringResource {
    switch self {
    case .firstEntry: "Every journey begins with a single moment."
    case .fiveStars: "Your gratitude practice is gaining momentum."
    case .shutterbug: "Photos can bring a meaningful feeling back into focus."
    case .expressive: "You are preserving memories in words and images."
    case .perfectTen: "You have built a thoughtful new habit."
    }
  }

  var symbolName: String {
    switch self {
    case .firstEntry: "figure.walk"
    case .fiveStars: "star.fill"
    case .shutterbug: "camera.fill"
    case .expressive: "text.below.photo.fill"
    case .perfectTen: "medal.fill"
    }
  }

  var color: Color {
    switch self {
    case .firstEntry: .orange
    case .fiveStars: .pink
    case .shutterbug: .blue
    case .expressive: .teal
    case .perfectTen: .purple
    }
  }
}

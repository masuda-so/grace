import SwiftData
import SwiftUI

struct AchievementsView: View {
  @Query(filter: #Predicate<Badge> { $0.timestamp != nil })
  private var unlockedBadges: [Badge]

  @Query(filter: #Predicate<Badge> { $0.timestamp == nil })
  private var lockedBadges: [Badge]

  @Query(sort: \Moment.timestamp)
  private var moments: [Moment]

  var body: some View {
    NavigationStack {
      ScrollView {
        contentStack
      }
      .navigationTitle("Achievements")
    }
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
  }

  private var contentStack: some View {
    VStack(alignment: .leading) {
      StreakView(numberOfDays: StreakCalculator().calculateStreak(for: moments))
        .frame(maxWidth: .infinity)
      if !unlockedBadges.isEmpty {
        header("Your Badges")
        ScrollView(.horizontal) {
          HStack {
            ForEach(sortedUnlockedBadges) { badge in
              UnlockedBadgeView(badge: badge)
            }
          }
        }
        .scrollClipDisabled()
        .scrollIndicators(.hidden)
      }
      if !lockedBadges.isEmpty {
        header("Locked Badges")
        ForEach(sortedLockedBadges) { badge in
          LockedBadgeView(badge: badge)
        }
      }
    }
    .padding()
    .frame(maxWidth: .infinity)
  }

  func header(_ text: LocalizedStringResource) -> some View {
    Text(text)
      .font(.subheadline.bold())
      .padding()
  }

  /// - precondition: `unlockedBadges` must have a timestamp
  private var sortedUnlockedBadges: [Badge] {
    // swift-format-ignore: NeverForceUnwrap
    unlockedBadges.sorted {
      ($0.timestamp!, String(localized: $0.details.title))
        < ($1.timestamp!, String(localized: $1.details.title))
    }
  }

  private var sortedLockedBadges: [Badge] {
    lockedBadges.sorted {
      $0.details.rawValue < $1.details.rawValue
    }
  }
}

#Preview {
  AchievementsView()
    .sampleDataContainer()
}

import Foundation

struct StreakCalculator {
  let calendar = Calendar.current

  /// Counts consecutive calendar days ending today or yesterday.
  /// - precondition: `moments` must be sorted by timestamp, from earliest to latest.
  func calculateStreak(for moments: [Moment]) -> Int {
    let startOfToday = calendar.startOfDay(for: .now)
    // swift-format-ignore: NeverForceUnwrap
    let endOfToday = calendar.date(
      byAdding: DateComponents(day: 1, second: -1),
      to: startOfToday
    )!

    let daysAgoArray =
      moments
      .reversed()
      .map(\.timestamp)
      .map { calendar.dateComponents([.day], from: $0, to: endOfToday) }
      .compactMap { $0.day }

    var streak = 0
    for daysAgo in daysAgoArray {
      if daysAgo == streak {
        continue
      } else if daysAgo == streak + 1 {
        streak += 1
      } else {
        break
      }
    }

    if daysAgoArray.first == 0 {
      streak += 1
    }

    return streak
  }
}

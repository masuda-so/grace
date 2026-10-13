import Foundation
import SwiftData

/// Use `timestamp` to determine if a badge is unlocked.
///
/// A `Moment` may be deleted but the timestamp stays.
/// Once awarded, badges aren't relocked.
@Model
class Badge {
  var details: BadgeDetails
  var moment: Moment?
  var timestamp: Date?

  init(details: BadgeDetails) {
    self.details = details
    self.moment = nil
    self.timestamp = nil
  }
}

extension Badge {
  static var sample: Badge {
    let badge = Badge(details: .firstEntry)
    badge.timestamp = .now
    return badge
  }
}

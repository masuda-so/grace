#if DEBUG
  import Foundation
  import SwiftData

  /// Provides explicit Debug-only fixtures.
  ///
  /// Capture mode never opens the user's store.
  @MainActor
  enum StoreCaptureFixtures {
    static func makeContainer() -> DataContainer {
      let args = ProcessInfo.processInfo.arguments
      guard args.contains("--store-capture") else { return DataContainer() }
      let container = DataContainer(isStoredInMemoryOnly: true)
      guard !args.contains("--capture-empty") else { return container }
      let japanese = Locale.current.language.languageCode?.identifier == "ja"
      let titles =
        japanese
        ? ["うれしいひと言", "静かな散歩", "温かいお茶"]
        : ["A kind word", "A quiet walk", "A warm cup of tea"]
      let notes =
        japanese
        ? ["何気ないひと言に、元気をもらった。", "少し遠回りして、季節の変化に気づいた。", "忙しい一日の終わりに、少しだけゆっくりできた。"]
        : [
          "A small kindness brightened my day.",
          "A longer walk helped me notice the changing season.", "A small pause after a busy day.",
        ]
      let photoURL =
        Bundle.main.url(forResource: "CaptureTea", withExtension: "png")
        ?? URL.documentsDirectory.appending(path: "capture-photo.png")
      let photo = try? Data(contentsOf: photoURL)
      do {
        try container.context.performTransactionOrRollback {
          for index in titles.indices {
            guard let date = Calendar.current.date(byAdding: .day, value: index - 2, to: .now)
            else { continue }
            let moment = Moment(
              title: titles[index], note: notes[index],
              imageData: index == 2 ? photo : nil, timestamp: date
            )
            container.context.insert(moment)
            try container.badgeManager.unlockBadges(newMoment: moment)
          }
        }
      } catch {
        assertionFailure("Capture fixtures could not be prepared: \(error)")
      }
      return container
    }
  }
#endif

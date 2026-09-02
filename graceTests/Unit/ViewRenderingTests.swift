import SwiftUI
import UIKit
import XCTest

@testable import grace

@MainActor
final class ViewRenderingTests: XCTestCase {
  func testTutorialViewUnitsRender() {
    let views: [AnyView] = [
      AnyView(
        Hexagon(moment: Moment.imageSample) {
          Text(Moment.imageSample.title)
        }
        .sampleDataContainer()
      ),
      AnyView(
        NavigationStack {
          HexagonAccessoryView(moment: .imageSample, hexagonLayout: .standard)
        }
        .sampleDataContainer()
      ),
      AnyView(AchievementsView().sampleDataContainer()),
      AnyView(BadgeDetailView(badge: .sample)),
      AnyView(LockedBadgeView(badge: .sample)),
      AnyView(StreakView(numberOfDays: 3)),
      AnyView(
        NavigationStack {
          UnlockedBadgeView(badge: .sample)
        }
      ),
      AnyView(MomentHexagonView(moment: .imageSample).sampleDataContainer()),
      AnyView(MomentsView().sampleDataContainer()),
      AnyView(MomentDetailView(moment: .imageSample).sampleDataContainer()),
      AnyView(MomentEntryView().sampleDataContainer()),
      AnyView(
        AssistantView(selection: .constant(.assistant))
          .environment(AppEnvironment.preview)
          .sampleDataContainer()
      ),
      AnyView(
        AssistantMomentReviewView(
          draft: AssistantMomentDraft(
            title: "A kind message",
            note: "A friend checked in.",
            timestamp: Date(timeIntervalSince1970: 1_788_237_123)
          )
        )
        .environment(\.locale, Locale(identifier: "ja_JP"))
        .environment(\.calendar, Calendar(identifier: .japanese))
        .environment(\.timeZone, TimeZone(secondsFromGMT: 32_400) ?? .gmt)
        .sampleDataContainer()
      ),
      AnyView(PaywallView().environment(AppEnvironment.preview)),
      AnyView(SettingsView().environment(AppEnvironment.preview)),
      AnyView(RestorePurchasesButton()),
      AnyView(CardView { Text("Card") }),
      AnyView(
        AppRootView()
          .environment(AppEnvironment.preview)
          .sampleDataContainer()
      ),
    ]

    for view in views {
      assertRenders(view)
    }
  }

  func testTutorialHexagonLayoutValues() {
    XCTAssertEqual(HexagonLayout.standard.size, 200)
    XCTAssertEqual(HexagonLayout.large.size, 350)
    XCTAssertEqual(
      HexagonLayout.standard.timestampHeight,
      HexagonLayout.standard.size
        * (HexagonLayout.standard.textBottomPadding - HexagonLayout.standard.timestampBottomPadding)
    )
  }

  private func assertRenders(
    _ view: AnyView,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    let size = CGSize(width: 430, height: 932)
    let controller = UIHostingController(rootView: view)
    controller.view.frame = CGRect(origin: .zero, size: size)
    controller.view.layoutIfNeeded()

    let image = UIGraphicsImageRenderer(size: size).image { context in
      controller.view.layer.render(in: context.cgContext)
    }
    XCTAssertNotNil(image.pngData(), file: file, line: line)
  }
}

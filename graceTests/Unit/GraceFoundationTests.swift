import Foundation
import ImageIO
import PhotosUI
import SwiftData
import SwiftUI
import UIKit
import UniformTypeIdentifiers
import XCTest

@testable import grace

final class GraceFoundationTests: XCTestCase {
  @MainActor
  func testProductIdentityMatchesBundleConvention() {
    let product = ProductDefinition.grace

    XCTAssertEqual(product.identifier, "grace")
    XCTAssertEqual(product.bundleIdentifier, "llc.ether.\(product.identifier)")
    XCTAssertEqual(
      GraceCommerceCatalog.dailyPassProductID,
      "\(product.bundleIdentifier).pro.daily"
    )
    XCTAssertEqual(
      GraceCommerceCatalog.monthlyProductID,
      "\(product.bundleIdentifier).pro.monthly"
    )
    XCTAssertEqual(
      GraceCommerceCatalog.yearlyProductID,
      "\(product.bundleIdentifier).pro.yearly"
    )
    XCTAssertEqual(
      GraceCommerceCatalog.catalog.nonRenewingDurations[GraceCommerceCatalog.dailyPassProductID],
      24 * 60 * 60
    )
    XCTAssertEqual(product.name, "Grace")
    XCTAssertFalse(product.tagline.isEmpty)
    XCTAssertEqual(
      product.privacyPolicyURL.absoluteString,
      "https://ether-llc.com/apps/grace/privacy/"
    )
    XCTAssertEqual(
      product.termsOfUseURL.absoluteString,
      "https://ether-llc.com/apps/grace/terms/"
    )
  }

  func testActiveDailyPassIsHiddenFromPurchaseOptions() {
    XCTAssertEqual(
      ProductID.offeredProductIDs(dailyPassIsActive: false),
      ProductID.all
    )
    XCTAssertEqual(
      ProductID.offeredProductIDs(dailyPassIsActive: true),
      ProductID.subscriptions
    )
    XCTAssertFalse(
      ProductID.offeredProductIDs(dailyPassIsActive: true).contains(
        GraceCommerceCatalog.dailyPassProductID
      )
    )
  }

  @MainActor
  func testApplicationSectionsRemainDistinct() {
    let sections: Set<AppSection> = [
      .moments,
      .achievements,
      .assistant,
      .pro,
      .settings,
    ]

    XCTAssertEqual(sections.count, 5)
  }

  @MainActor
  func testLegalURLsMatchPublishedRoutesAndLocale() {
    let product = ProductDefinition.grace
    let base = "https://ether-llc.com/apps/\(product.identifier)"
    let urls = [
      (product.privacyPolicyURL, "privacy"),
      (product.termsOfUseURL, "terms"),
      (product.supportURL, "support"),
    ]

    for (url, route) in urls {
      XCTAssertEqual(url.absoluteString, "\(base)/\(route)/")
      XCTAssertEqual(
        product.localizedLegalURL(url, for: Locale(identifier: "en_US")),
        url
      )

      let japaneseURL = product.localizedLegalURL(
        url,
        for: Locale(identifier: "ja_JP")
      )
      XCTAssertEqual(
        japaneseURL.absoluteString,
        "https://ether-llc.com/ja/apps/\(product.identifier)/\(route)/"
      )
      XCTAssertEqual(
        product.localizedLegalURL(japaneseURL, for: Locale(identifier: "ja_JP")),
        japaneseURL
      )
    }
  }

  @MainActor
  func testDailyPassControlsProAccessAtExpiration() {
    let expiration = Date(timeIntervalSince1970: 100_000)
    let entitlements = EntitlementSnapshot(
      activeProductIDs: [GraceCommerceCatalog.dailyPassProductID],
      expirationDates: [GraceCommerceCatalog.dailyPassProductID: expiration]
    )

    XCTAssertTrue(
      entitlements.hasPremiumAccess(
        in: GraceCommerceCatalog.catalog,
        at: expiration.addingTimeInterval(-1)
      )
    )
    XCTAssertFalse(
      entitlements.hasPremiumAccess(in: GraceCommerceCatalog.catalog, at: expiration)
    )
  }

  @MainActor
  func testAppEnvironmentUsesInjectedDateForDailyPassAccess() {
    let expiration = Date(timeIntervalSince1970: 100_000)
    let entitlements = EntitlementSnapshot(
      activeProductIDs: [GraceCommerceCatalog.dailyPassProductID],
      expirationDates: [GraceCommerceCatalog.dailyPassProductID: expiration]
    )
    let environmentBeforeExpiration = AppEnvironment(
      aiClient: UnavailableAIClient(reason: .modelNotReady),
      subscriptionClient: PreviewSubscriptionClient(),
      currentDate: { expiration.addingTimeInterval(-1) }
    )
    environmentBeforeExpiration.entitlements = entitlements
    XCTAssertTrue(environmentBeforeExpiration.isPremium)
    XCTAssertTrue(
      environmentBeforeExpiration.isProductActive(GraceCommerceCatalog.dailyPassProductID)
    )

    let environmentAtExpiration = AppEnvironment(
      aiClient: UnavailableAIClient(reason: .modelNotReady),
      subscriptionClient: PreviewSubscriptionClient(),
      currentDate: { expiration }
    )
    environmentAtExpiration.entitlements = entitlements
    XCTAssertFalse(environmentAtExpiration.isPremium)
    XCTAssertFalse(
      environmentAtExpiration.isProductActive(GraceCommerceCatalog.dailyPassProductID)
    )
  }

  func testExpirationDelayUsesInjectedCurrentDate() {
    let currentDate = Date(timeIntervalSince1970: 1_000)

    XCTAssertEqual(
      AppEnvironment.expirationDelay(
        until: currentDate.addingTimeInterval(60),
        from: currentDate
      ),
      .seconds(60)
    )
    XCTAssertEqual(
      AppEnvironment.expirationDelay(
        until: currentDate.addingTimeInterval(-1),
        from: currentDate
      ),
      .zero
    )
  }

  @MainActor
  func testMomentDefaultsToTheCurrentDate() {
    let beforeCreation = Date.now
    let moment = Moment(title: "A kind word", note: "")

    XCTAssertEqual(moment.title, "A kind word")
    XCTAssertTrue(moment.note.isEmpty)
    XCTAssertNil(moment.imageData)
    XCTAssertGreaterThanOrEqual(moment.timestamp, beforeCreation)
  }

  @MainActor
  func testDataContainerCreatesEditsAndDeletesMoment() throws {
    let dataContainer = DataContainer(isStoredInMemoryOnly: true)
    let moment = Moment(title: "Morning light", note: "A quiet beginning")

    dataContainer.context.insert(moment)
    try dataContainer.context.save()

    let savedMoments = try dataContainer.context.fetch(FetchDescriptor<Moment>())
    XCTAssertEqual(savedMoments.count, 1)
    XCTAssertEqual(savedMoments.first?.title, "Morning light")

    let saved = try XCTUnwrap(savedMoments.first)
    saved.note = "A revised beginning"
    try dataContainer.context.save()
    XCTAssertEqual(
      try dataContainer.context.fetch(FetchDescriptor<Moment>()).first?.note,
      "A revised beginning"
    )

    dataContainer.context.delete(saved)
    try dataContainer.context.save()
    XCTAssertTrue(try dataContainer.context.fetch(FetchDescriptor<Moment>()).isEmpty)
  }

  @MainActor
  func testPreviewContainersUseDistinctSampleInstances() throws {
    let firstContainer = DataContainer(
      isStoredInMemoryOnly: true,
      includesSampleMoments: true
    )
    let secondContainer = DataContainer(
      isStoredInMemoryOnly: true,
      includesSampleMoments: true
    )

    let firstMoment = try XCTUnwrap(
      firstContainer.context.fetch(FetchDescriptor<Moment>()).first
    )
    let secondMoment = try XCTUnwrap(
      secondContainer.context.fetch(FetchDescriptor<Moment>()).first
    )

    XCTAssertFalse(firstMoment === secondMoment)
  }

  @MainActor
  func testFailedTransactionDiscardsPendingMoment() throws {
    let dataContainer = DataContainer(isStoredInMemoryOnly: true)

    XCTAssertThrowsError(
      try dataContainer.context.performTransactionOrRollback {
        dataContainer.context.insert(Moment(title: "Unsaved", note: ""))
        throw CocoaError(.fileWriteNoPermission)
      }
    )

    XCTAssertTrue(try dataContainer.context.fetch(FetchDescriptor<Moment>()).isEmpty)
  }

  @MainActor
  func testFailedEditRestoresPersistedMoment() throws {
    let dataContainer = DataContainer(isStoredInMemoryOnly: true)
    let moment = Moment(title: "Saved", note: "Original")
    dataContainer.context.insert(moment)
    try dataContainer.context.save()

    XCTAssertThrowsError(
      try dataContainer.context.performTransactionOrRollback {
        moment.note = "Unsaved change"
        throw CocoaError(.fileWriteNoPermission)
      }
    )

    let saved = try XCTUnwrap(
      dataContainer.context.fetch(FetchDescriptor<Moment>()).first
    )
    XCTAssertEqual(saved.note, "Original")
  }

  @MainActor
  func testFailedDeleteRestoresPersistedMoment() throws {
    let dataContainer = DataContainer(isStoredInMemoryOnly: true)
    let moment = Moment(title: "Saved", note: "Original")
    dataContainer.context.insert(moment)
    try dataContainer.context.save()

    XCTAssertThrowsError(
      try dataContainer.context.performTransactionOrRollback {
        dataContainer.context.delete(moment)
        throw CocoaError(.fileWriteNoPermission)
      }
    )

    XCTAssertEqual(
      try dataContainer.context.fetch(FetchDescriptor<Moment>()).map(\.title),
      ["Saved"]
    )
  }

  func testSchemaUsesTutorialAttributeNames() throws {
    let schema = Schema([Moment.self, Badge.self])
    let moment = try XCTUnwrap(schema.entity(for: Moment.self))
    let badge = try XCTUnwrap(schema.entity(for: Badge.self))

    XCTAssertNotNil(moment.attributesByName["timestamp"])
    XCTAssertNotNil(badge.attributesByName["details"])
    XCTAssertNotNil(badge.attributesByName["timestamp"])
    XCTAssertNil(moment.attributesByName["createdAt"])
    XCTAssertNil(badge.attributesByName["kind"])
    XCTAssertNil(badge.attributesByName["unlockedAt"])
  }

  func testTransactionFailureTriggersRollback() {
    var didRollback = false

    XCTAssertThrowsError(
      try ModelContext.performTransactionOrRollback(
        transaction: { throw CocoaError(.fileWriteNoPermission) },
        rollback: { didRollback = true }
      )
    )
    XCTAssertTrue(didRollback)
  }

  @MainActor
  func testPhotoPreparationDownsamplesLargeImage() async throws {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 2_000, height: 1_000))
    let image = renderer.image { context in
      UIColor.orange.setFill()
      context.fill(CGRect(x: 0, y: 0, width: 2_000, height: 1_000))
    }
    let sourceData = try XCTUnwrap(image.jpegData(compressionQuality: 1))

    let preparedData = try await PhotoSelection.preparedImageData(from: sourceData)
    let source = try XCTUnwrap(
      CGImageSourceCreateWithData(preparedData as CFData, nil)
    )
    let properties = try XCTUnwrap(
      CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
    )
    let imageType = try XCTUnwrap(CGImageSourceGetType(source))

    XCTAssertEqual(properties[kCGImagePropertyPixelWidth] as? Int, 1_600)
    XCTAssertEqual(properties[kCGImagePropertyPixelHeight] as? Int, 800)
    XCTAssertEqual(imageType as String, UTType.jpeg.identifier)
  }

  @MainActor
  func testPhotoPreparationRejectsInvalidData() async {
    do {
      _ = try await PhotoSelection.preparedImageData(from: Data([0x00]))
      XCTFail("Expected invalid image data to be rejected.")
    } catch {
      // The concrete error is intentionally private to the photo service.
    }
  }

  func testPhotoSelectionAcceptsOnlyTheCurrentPickerItem() {
    let current = PhotosPickerItem(itemIdentifier: "current")
    let stale = PhotosPickerItem(itemIdentifier: "stale")

    XCTAssertTrue(PhotoSelection.isCurrentSelection(current, current: current))
    XCTAssertFalse(PhotoSelection.isCurrentSelection(stale, current: current))
    XCTAssertFalse(PhotoSelection.isCurrentSelection(current, current: nil))
  }

  @MainActor
  func testMomentEntryRequiresAndTrimsItsTitle() throws {
    XCTAssertNil(
      MomentEntryValidation.payload(title: " \n\t ", imageState: .empty)
    )

    let payload = try XCTUnwrap(
      MomentEntryValidation.payload(
        title: "  Morning light \n",
        imageState: .empty
      )
    )
    XCTAssertEqual(payload.title, "Morning light")
    XCTAssertNil(payload.imageData)
  }

  @MainActor
  func testMomentEntryWaitsForSelectedPhotoPreparation() throws {
    XCTAssertNotNil(
      MomentEntryValidation.payload(title: "Morning", imageState: .empty)
    )
    XCTAssertNil(
      MomentEntryValidation.payload(
        title: "Morning",
        imageState: .loading(Progress(totalUnitCount: 1))
      )
    )
    XCTAssertNil(
      MomentEntryValidation.payload(
        title: "Morning",
        imageState: .failure(CocoaError(.fileReadCorruptFile))
      )
    )

    let imageData = Data([1, 2, 3])
    let payload = try XCTUnwrap(
      MomentEntryValidation.payload(
        title: "Morning",
        imageState: .success(imageData)
      )
    )
    XCTAssertEqual(payload.imageData, imageData)
  }

  @MainActor
  func testStreakContinuesFromYesterday() {
    let calendar = Calendar.current
    let now = Date.now
    let moments = [-3, -2, -1].map { offset in
      Moment(
        title: "",
        note: "",
        timestamp: calendar.date(
          byAdding: .day,
          value: offset,
          to: now
        ) ?? now
      )
    }

    XCTAssertEqual(
      StreakCalculator().calculateStreak(for: moments),
      3
    )
  }

  @MainActor
  func testMultipleMomentsOnOneDayCountOnce() {
    let calendar = Calendar.current
    let now = Date.now
    let moments = [-1, 0, 0].map { offset in
      Moment(
        title: "",
        note: "",
        timestamp: calendar.date(
          byAdding: .day,
          value: offset,
          to: now
        ) ?? now
      )
    }

    XCTAssertEqual(
      StreakCalculator().calculateStreak(for: moments),
      2
    )
  }

  @MainActor
  func testBadgeCatalogDoesNotInsertDuplicates() throws {
    let dataContainer = DataContainer(isStoredInMemoryOnly: true)
    try dataContainer.badgeManager.loadBadgesIfNeeded()

    let badges = try dataContainer.context.fetch(FetchDescriptor<Badge>())
    XCTAssertEqual(Set(badges.map(\.details)), Set(BadgeDetails.allCases))
    XCTAssertEqual(badges.count, BadgeDetails.allCases.count)
  }

  @MainActor
  func testPerfectTenUnlocksWithOtherBadgesInTheSameEvaluation() throws {
    let dataContainer = DataContainer(isStoredInMemoryOnly: true)
    let imageData = try XCTUnwrap(UIImage(systemName: "photo")?.pngData())

    for index in 0..<10 {
      let moment = Moment(
        title: "Moment \(index)",
        note: index < 5 ? "A note" : "",
        imageData: index < 5 ? imageData : nil
      )
      dataContainer.context.insert(moment)
      try dataContainer.badgeManager.unlockBadges(newMoment: moment)
      try dataContainer.context.save()
    }

    let badges = try dataContainer.context.fetch(FetchDescriptor<Badge>())
    XCTAssertEqual(
      Set(badges.compactMap { $0.timestamp == nil ? nil : $0.details }),
      Set(BadgeDetails.allCases)
    )
  }
}

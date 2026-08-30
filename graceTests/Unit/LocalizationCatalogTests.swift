import Foundation
import XCTest

final class LocalizationCatalogTests: XCTestCase {
  func testActiveStringsHaveCompleteJapaneseTranslations() throws {
    let requiredRuntimeKeys: Set<String> = [
      "%@ Pro was restored.",
      "No active %@ Pro purchase was found.",
    ]

    for catalogURL in try catalogURLs() {
      let data = try Data(contentsOf: catalogURL)
      let object = try XCTUnwrap(
        JSONSerialization.jsonObject(with: data) as? [String: Any]
      )

      XCTAssertEqual(object["sourceLanguage"] as? String, "en", catalogURL.path)
      let strings = try XCTUnwrap(object["strings"] as? [String: Any])
      var issues: [String] = []

      for key in strings.keys.sorted() {
        guard let entry = strings[key] as? [String: Any] else {
          issues.append("\(key): invalid catalog entry")
          continue
        }
        if entry["extractionState"] as? String == "stale" {
          if requiredRuntimeKeys.contains(key) {
            issues.append("\(key): runtime string is marked stale")
          }
          continue
        }
        if entry["shouldTranslate"] as? Bool == false {
          continue
        }

        let localizations = entry["localizations"] as? [String: Any]
        guard let japanese = localizations?["ja"] else {
          issues.append("\(key): missing Japanese localization")
          continue
        }

        validate(
          units: stringUnits(in: japanese),
          language: "ja",
          sourceKey: key,
          issues: &issues
        )

        if let english = localizations?["en"] {
          validate(
            units: stringUnits(in: english),
            language: "en",
            sourceKey: key,
            issues: &issues
          )
        }
      }

      XCTAssertTrue(
        issues.isEmpty,
        "\(catalogURL.lastPathComponent):\n\(issues.joined(separator: "\n"))"
      )
    }
  }

  private func catalogURLs() throws -> [URL] {
    let unitDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    let testTargetDirectory = unitDirectory.deletingLastPathComponent()
    let repository = testTargetDirectory.deletingLastPathComponent()
    let productName = testTargetDirectory.lastPathComponent.replacingOccurrences(
      of: "Tests",
      with: ""
    )
    let resources =
      repository
      .appendingPathComponent(productName)
      .appendingPathComponent("Resources")
    let urls = try FileManager.default.contentsOfDirectory(
      at: resources,
      includingPropertiesForKeys: nil
    ).filter { $0.pathExtension == "xcstrings" }

    return try XCTUnwrap(urls.isEmpty ? nil : urls.sorted { $0.path < $1.path })
  }

  private func stringUnits(in value: Any) -> [[String: Any]] {
    if let dictionary = value as? [String: Any] {
      var units: [[String: Any]] = []
      if let unit = dictionary["stringUnit"] as? [String: Any] {
        units.append(unit)
      }
      for child in dictionary.values {
        units.append(contentsOf: stringUnits(in: child))
      }
      return units
    }
    if let array = value as? [Any] {
      return array.flatMap(stringUnits(in:))
    }
    return []
  }

  private func validate(
    units: [[String: Any]],
    language: String,
    sourceKey: String,
    issues: inout [String]
  ) {
    if units.isEmpty {
      issues.append("\(sourceKey): \(language) has no translated string unit")
      return
    }

    for unit in units {
      guard unit["state"] as? String == "translated",
        let value = unit["value"] as? String,
        !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      else {
        issues.append("\(sourceKey): \(language) is not translated")
        continue
      }

      if placeholders(in: value) != placeholders(in: sourceKey) {
        issues.append("\(sourceKey): \(language) format placeholders differ")
      }
    }
  }

  private func placeholders(in value: String) -> [String] {
    let pattern = #"%(?:\d+\$)?(?:[-+#0 ']*)(?:\d+)?(?:\.\d+)?(?:hh|h|ll|l|q|z|t|j)?[@A-Za-z]"#
    guard let expression = try? NSRegularExpression(pattern: pattern) else {
      return []
    }
    let range = NSRange(value.startIndex..., in: value)
    return expression.matches(in: value, range: range).compactMap {
      Range($0.range, in: value).map { String(value[$0]) }
    }.sorted()
  }
}

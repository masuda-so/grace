import Foundation
import XCTest

/// Finds test-only fixtures in the test bundle on both devices and simulators.
enum TestResources {
  static func url(forResource name: String, withExtension fileExtension: String) throws -> URL {
    try XCTUnwrap(
      Bundle(for: TestResourceBundleMarker.self).url(
        forResource: name,
        withExtension: fileExtension
      ),
      "Missing test resource: \(name).\(fileExtension)"
    )
  }
}

private final class TestResourceBundleMarker {}

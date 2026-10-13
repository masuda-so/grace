/*
See the THIRD_PARTY_NOTICES.md file for this sample’s licensing information.

Abstract:
The restore purchases button.
*/

import Foundation
import OSLog
import StoreKit
import SwiftUI

struct RestorePurchasesButton: View {
  private static let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "llc.ether.grace",
    category: "StoreKit"
  )

  @Environment(AppEnvironment.self) private var environment
  @State private var isRestoring = false
  @State private var restoreMessage: String?
  @State private var restoreFailed = false

  var body: some View {
    Button {
      Task {
        isRestoring = true
        defer { isRestoring = false }

        do {
          let restoredPro = try await environment.restorePurchases()
          restoreFailed = false
          restoreMessage =
            restoredPro
            ? String(localized: "\(environment.product.name) Pro was restored.")
            : String(localized: "No active \(environment.product.name) Pro purchase was found.")
        } catch is CancellationError {
          return
        } catch {
          Self.logger.error(
            "Could not restore purchases: \(String(describing: error), privacy: .private)"
          )
          restoreFailed = true
          restoreMessage =
            SubscriptionError.storeUnavailable(
              debugDescription: String(describing: error)
            ).localizedDescription
        }
      }
    } label: {
      if isRestoring {
        HStack {
          ProgressView()
          Text("Restoring Purchases…")
        }
      } else {
        Text("Restore Purchases")
      }
    }
    .disabled(isRestoring)
    .alert(
      restoreFailed ? "Restore Failed" : "Restore Purchases",
      isPresented: Binding(
        get: { restoreMessage != nil },
        set: { if !$0 { restoreMessage = nil } }
      )
    ) {
      Button("OK", role: .cancel) {}
    } message: {
      Text(restoreMessage ?? "")
    }
  }
}

#Preview {
  RestorePurchasesButton()
    .environment(AppEnvironment.preview)
}

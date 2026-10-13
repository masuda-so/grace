import Foundation
import Observation
import OSLog

/// Coordinates assistant, StoreKit, and access state for the application UI.
@MainActor
@Observable
final class AppEnvironment {
  private static let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "llc.ether.grace",
    category: "FoundationModels"
  )

  let product: ProductDefinition

  private let assistant: GraceAssistant
  private let subscriptionClient: any SubscriptionClient
  private let currentDate: @Sendable () -> Date
  private let sleep: @Sendable (Duration) async throws -> Void
  private var entitlementTask: Task<Void, Never>?
  private var expirationTask: Task<Void, Never>?

  var aiAvailability: AIAvailability = .unavailable(.unknown)
  var entitlements = EntitlementSnapshot() {
    didSet {
      scheduleNextNonRenewingExpiration()
    }
  }
  var assistantResponse: String?
  var assistantErrorMessage: String?
  var isGenerating = false
  var hasLoadedInitialState = false

  init(
    aiClient: any AIClient = AIClientFactory.makeDefault(),
    subscriptionClient: (any SubscriptionClient)? = nil,
    currentDate: @escaping @Sendable () -> Date = Date.init,
    sleep: @escaping @Sendable (Duration) async throws -> Void = {
      try await Task.sleep(for: $0)
    }
  ) {
    self.product = .grace
    self.assistant = GraceAssistant(client: aiClient, product: .grace)
    self.currentDate = currentDate
    self.sleep = sleep
    self.subscriptionClient =
      subscriptionClient
      ?? StoreKitSubscriptionClient(
        catalog: GraceCommerceCatalog.catalog,
        now: currentDate
      )
  }

  /// Starts transaction monitoring and loads the initial assistant and StoreKit state.
  func start() async {
    hasLoadedInitialState = false
    defer { hasLoadedInitialState = true }

    if entitlementTask == nil {
      startEntitlementMonitor()
    }

    async let availability = assistant.availability
    async let currentEntitlements = subscriptionClient.currentEntitlements()

    aiAvailability = await availability
    entitlements = await currentEntitlements
  }

  /// Restores App Store purchases and immediately applies the refreshed access state.
  func restorePurchases() async throws -> Bool {
    entitlements = try await subscriptionClient.restorePurchases()
    return isPremium
  }

  private func startEntitlementMonitor() {
    let subscriptionClient = self.subscriptionClient
    entitlementTask = Task { [weak self, subscriptionClient] in
      let updates = await subscriptionClient.entitlementUpdates()
      for await snapshot in updates {
        guard !Task.isCancelled else { break }
        self?.entitlements = snapshot
      }
    }
  }

  private func scheduleNextNonRenewingExpiration() {
    expirationTask?.cancel()
    expirationTask = nil

    let currentDate = currentDate()
    guard
      let expirationDate = entitlements.nextNonRenewingExpiration(
        in: GraceCommerceCatalog.catalog,
        after: currentDate
      )
    else {
      return
    }

    let delay = Self.expirationDelay(
      until: expirationDate,
      from: currentDate
    )
    let subscriptionClient = self.subscriptionClient
    let sleep = self.sleep
    expirationTask = Task { [weak self, subscriptionClient, sleep] in
      do {
        try await sleep(delay)
      } catch {
        return
      }
      guard !Task.isCancelled else { return }
      self?.entitlements = await subscriptionClient.currentEntitlements()
    }
  }

  isolated deinit {
    entitlementTask?.cancel()
    expirationTask?.cancel()
  }

  /// Requests an assistant response and publishes the resulting UI state.
  func requestAssistantResponse(for text: String) async {
    guard !isGenerating else { return }

    assistantResponse = nil
    assistantErrorMessage = nil

    guard isAIAvailable else {
      assistantErrorMessage = String(localized: "The on-device assistant is unavailable.")
      return
    }

    guard isPremium else {
      assistantErrorMessage = String(localized: "Choose a Pro plan to use the on-device assistant.")
      return
    }

    isGenerating = true
    defer { isGenerating = false }

    do {
      let response = try await assistant.respond(to: text)
      try Task.checkCancellation()
      assistantResponse = response
    } catch AIError.cancelled {
      return
    } catch is CancellationError {
      return
    } catch let error as AIError {
      assistantErrorMessage = error.localizedDescription
    } catch {
      Self.logger.error(
        "Unexpected assistant error: \(String(describing: error), privacy: .private)"
      )
      assistantErrorMessage =
        AIError.generationFailed(
          debugDescription: String(describing: error)
        ).localizedDescription
    }
  }

  var isPremium: Bool {
    GraceAccessPolicy.grantsProAccess(for: entitlements, at: currentDate())
  }

  var isAIAvailable: Bool {
    aiAvailability == .available
  }

  /// Returns whether a configured product currently grants access.
  func isProductActive(_ productID: String) -> Bool {
    entitlements.isActive(
      productID: productID,
      in: GraceCommerceCatalog.catalog,
      at: currentDate()
    )
  }

  /// Returns a nonnegative delay from an injected wall-clock date to an expiration.
  nonisolated static func expirationDelay(
    until expirationDate: Date,
    from currentDate: Date
  ) -> Duration {
    .seconds(max(expirationDate.timeIntervalSince(currentDate), 0))
  }

  static var preview: AppEnvironment {
    let environment = AppEnvironment(
      aiClient: UnavailableAIClient(reason: .modelNotReady),
      subscriptionClient: PreviewSubscriptionClient()
    )
    environment.hasLoadedInitialState = true
    return environment
  }
}

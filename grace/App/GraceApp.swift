import SwiftData
import SwiftUI

@main
struct GraceApp: App {
  @Environment(\.scenePhase) private var scenePhase
  @State private var environment = AppEnvironment()
  @State private var dataContainer = DataContainer()

  var body: some Scene {
    WindowGroup {
      AppRootView()
        .environment(environment)
        .environment(dataContainer)
        .modelContainer(dataContainer.modelContainer)
        .task {
          await environment.start()
        }
        .onChange(of: scenePhase) { _, phase in
          guard phase == .active else { return }
          Task {
            await environment.refreshAIAvailability()
          }
        }
    }
  }
}

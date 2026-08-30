import SwiftData
import SwiftUI

@main
struct GraceApp: App {
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
    }
  }
}

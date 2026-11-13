import SwiftData
import SwiftUI

@main
struct GraceApp: App {
  @State private var environment = AppEnvironment()
  @State private var dataContainer: DataContainer

  init() {
    #if DEBUG
      _dataContainer = State(initialValue: StoreCaptureFixtures.makeContainer())
    #else
      _dataContainer = State(initialValue: DataContainer())
    #endif
  }

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

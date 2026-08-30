import SwiftUI

enum AppSection: Hashable {
  case moments
  case achievements
  case assistant
  case pro
  case settings
}

struct AppRootView: View {
  @Environment(AppEnvironment.self) private var environment
  @State private var selection: AppSection = .moments

  var body: some View {
    TabView(selection: $selection) {
      Tab("Moments", systemImage: "hexagon.fill", value: .moments) {
        MomentsView()
      }

      Tab("Achievements", systemImage: "medal.fill", value: .achievements) {
        AchievementsView()
      }

      Tab("Assistant", systemImage: "sparkles", value: .assistant) {
        AssistantView(selection: $selection)
      }

      Tab("Pro", systemImage: "crown", value: .pro) {
        PaywallView()
      }

      Tab("Settings", systemImage: "gearshape", value: .settings) {
        SettingsView()
      }
    }
    .tint(environment.product.accent)
  }
}

#Preview {
  AppRootView()
    .environment(AppEnvironment.preview)
    .sampleDataContainer()
}

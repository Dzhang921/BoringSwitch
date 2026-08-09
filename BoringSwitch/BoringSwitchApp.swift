import SwiftUI
import WidgetKit

@main
struct BoringSwitchApp: App {
    @StateObject private var clickStore = ClickStore()
    @StateObject private var premiumStore = PremiumStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(clickStore)
                .environmentObject(premiumStore)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                WidgetCenter.shared.reloadTimelines(ofKind: "LifetimeClicks")
            }
        }
    }
}

import SwiftUI

@main
struct BoringSwitchApp: App {
    @StateObject private var clickStore = ClickStore()
    @StateObject private var premiumStore = PremiumStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(clickStore)
                .environmentObject(premiumStore)
        }
    }
}

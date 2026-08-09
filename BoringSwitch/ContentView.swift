import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var clickStore: ClickStore
    @EnvironmentObject private var premiumStore: PremiumStore

    @AppStorage("isOn") private var isOn = false
    @AppStorage("switchStyle") private var styleRaw = SwitchStyle.toggle.rawValue
    @AppStorage("switchMaterial") private var materialRaw = SwitchMaterial.plastic.rawValue
    @AppStorage("colorway") private var colorwayRaw = Colorway.white.rawValue

    @State private var showCustomize = false
    @State private var showStats = false
    @State private var showPaywall = false
    @State private var milestoneMessage: String?
    @State private var milestoneTask: Task<Void, Never>?

    private var style: SwitchStyle { SwitchStyle(rawValue: styleRaw) ?? .toggle }
    private var material: SwitchMaterial { SwitchMaterial(rawValue: materialRaw) ?? .plastic }
    private var colorway: Colorway { Colorway(rawValue: colorwayRaw) ?? .white }

    private var roomColor: Color {
        isOn ? Color(red: 0.96, green: 0.94, blue: 0.90) : Color(red: 0.04, green: 0.04, blue: 0.05)
    }
    private var inkColor: Color {
        isOn ? Color(red: 0.15, green: 0.14, blue: 0.13) : Color(white: 0.85)
    }

    var body: some View {
        ZStack {
            roomColor.ignoresSafeArea()

            // Soft lamp glow behind the switch when the light is on
            if isOn {
                RadialGradient(colors: [Color.yellow.opacity(0.22), .clear],
                               center: .center, startRadius: 20, endRadius: 380)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            VStack(spacing: 0) {
                counter
                    .padding(.top, 36)

                Spacer()

                SwitchAssemblyView(style: style, material: material,
                                   colorway: colorway, isOn: isOn, flip: flip)

                Spacer()

                bottomBar
                    .padding(.bottom, 24)
            }

            if let message = milestoneMessage {
                milestoneToast(message)
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.62), value: isOn)
        .sheet(isPresented: $showCustomize) {
            CustomizeView(styleRaw: $styleRaw, materialRaw: $materialRaw,
                          colorwayRaw: $colorwayRaw, showPaywall: $showPaywall)
        }
        .sheet(isPresented: $showStats) { StatsView() }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .onChange(of: premiumStore.isPremiumActive) { _, active in
            // Trial expired: quietly fall back to the free configuration.
            if !active {
                if !style.isFree { styleRaw = SwitchStyle.toggle.rawValue }
                if !material.isFree { materialRaw = SwitchMaterial.plastic.rawValue }
                if !colorway.isFree { colorwayRaw = Colorway.white.rawValue }
            }
        }
    }

    private var counter: some View {
        VStack(spacing: 4) {
            Text("\(clickStore.lifetimeClicks)")
                .font(.system(size: 54, weight: .light, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
            Text("lifetime clicks")
                .font(.footnote.smallCaps())
                .opacity(0.6)
        }
        .foregroundStyle(inkColor)
    }

    private var bottomBar: some View {
        HStack(spacing: 40) {
            Button { showCustomize = true } label: {
                Label("Customize", systemImage: "paintpalette")
            }
            Button { showStats = true } label: {
                Label("Stats", systemImage: "chart.bar")
            }
        }
        .font(.subheadline)
        .foregroundStyle(inkColor.opacity(0.7))
        .buttonStyle(.plain)
    }

    private func milestoneToast(_ message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.horizontal, 30)
                .padding(.bottom, 90)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func flip() {
        isOn.toggle()
        ClickSoundPlayer.shared.play(style: style, material: material, isOn: isOn)

        if let message = clickStore.registerClick() {
            milestoneTask?.cancel()
            withAnimation { milestoneMessage = message }
            milestoneTask = Task {
                try? await Task.sleep(for: .seconds(4))
                guard !Task.isCancelled else { return }
                withAnimation { milestoneMessage = nil }
            }
        }
    }
}

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var clickStore: ClickStore

    @AppStorage("isOn") private var isOn = false
    @AppStorage("switchStyle") private var styleRaw = SwitchStyle.toggle.rawValue
    @AppStorage("switchMaterial") private var materialRaw = SwitchMaterial.plastic.rawValue
    @AppStorage("colorway") private var colorwayRaw = Colorway.white.rawValue

    @State private var showCustomize = false
    @State private var showStats = false
    @State private var milestoneMessage: String?
    @State private var milestoneTask: Task<Void, Never>?
    @State private var flickerDim = false
    @State private var mothVisible = false

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

            // Rare event: the light flickers
            if flickerDim {
                Color.black.opacity(0.82).ignoresSafeArea()
            }

            // Rare event: a moth found the light
            if mothVisible {
                MothView()
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
                          colorwayRaw: $colorwayRaw)
        }
        .sheet(isPresented: $showStats) { StatsView() }
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
        maybeTriggerRareEvent()

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

    /// Occasionally, something almost happens. Discovered, never announced.
    private func maybeTriggerRareEvent() {
        guard isOn else { return }

        let roll = Int.random(in: 1...1200)
        if roll <= 3 {
            // ~1 in 400: the light flickers before settling
            clickStore.registerRareEvent()
            Task {
                for delay in [0.06, 0.09, 0.05, 0.12, 0.07] {
                    flickerDim.toggle()
                    try? await Task.sleep(for: .seconds(delay))
                }
                flickerDim = false
            }
        } else if roll == 4 {
            // ~1 in 1200: a moth drops by
            clickStore.registerRareEvent()
            Task {
                withAnimation(.easeIn(duration: 1.5)) { mothVisible = true }
                try? await Task.sleep(for: .seconds(7))
                withAnimation(.easeOut(duration: 1.5)) { mothVisible = false }
            }
        }
    }
}

/// A small moth that wanders around the glow while the light is on.
struct MothView: View {
    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let x = sin(t * 0.9) * 90 + sin(t * 2.3) * 28
            let y = cos(t * 0.7) * 110 + sin(t * 1.7) * 22 - 120
            let flap = sin(t * 26) * 32

            ZStack {
                Ellipse() // left wing
                    .fill(Color(white: 0.55, opacity: 0.85))
                    .frame(width: 10, height: 6)
                    .rotationEffect(.degrees(-20 + flap), anchor: .trailing)
                    .offset(x: -5)
                Ellipse() // right wing
                    .fill(Color(white: 0.55, opacity: 0.85))
                    .frame(width: 10, height: 6)
                    .rotationEffect(.degrees(20 - flap), anchor: .leading)
                    .offset(x: 5)
                Capsule() // body
                    .fill(Color(white: 0.35))
                    .frame(width: 3.5, height: 9)
            }
            .offset(x: x, y: y)
        }
        .allowsHitTesting(false)
    }
}

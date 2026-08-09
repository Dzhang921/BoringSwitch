import SwiftUI

/// Renders the selected switch. The whole assembly is tappable; the parent
/// owns the on/off state and side effects.
struct SwitchAssemblyView: View {
    let style: SwitchStyle
    let material: SwitchMaterial
    let colorway: Colorway
    let isOn: Bool
    let flip: () -> Void

    var body: some View {
        Group {
            switch style {
            case .toggle: ToggleSwitchView(material: material, colorway: colorway, isOn: isOn)
            case .rocker: RockerSwitchView(material: material, colorway: colorway, isOn: isOn)
            case .push: PushButtonView(material: material, colorway: colorway, isOn: isOn)
            case .knife: KnifeSwitchView(material: material, colorway: colorway, isOn: isOn)
            case .chain: PullChainView(material: material, colorway: colorway, isOn: isOn)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { flip() }
        .accessibilityLabel("Light switch")
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Shared plate

struct WallPlate<Content: View>: View {
    let colorway: Colorway
    var width: CGFloat = 150
    var height: CGFloat = 230
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(colorway.plateColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(
                            LinearGradient(colors: [.white.opacity(0.35), .black.opacity(0.2)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.35), radius: 14, y: 8)

            VStack {
                ScrewView(colorway: colorway)
                Spacer()
                ScrewView(colorway: colorway)
            }
            .padding(.vertical, 14)

            content
        }
        .frame(width: width, height: height)
    }
}

struct ScrewView: View {
    let colorway: Colorway

    var body: some View {
        Circle()
            .fill(colorway.detailColor)
            .frame(width: 9, height: 9)
            .overlay(
                Rectangle()
                    .fill(Color.black.opacity(0.35))
                    .frame(width: 7, height: 1.2)
                    .rotationEffect(.degrees(40))
            )
    }
}

// MARK: - Classic toggle

struct ToggleSwitchView: View {
    let material: SwitchMaterial
    let colorway: Colorway
    let isOn: Bool

    var body: some View {
        WallPlate(colorway: colorway) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.black.opacity(0.25))
                    .frame(width: 44, height: 108)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.3), lineWidth: 1)
                    )

                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(material.actuatorGradient)
                    .frame(width: 26, height: 48)
                    .shadow(color: .black.opacity(0.4), radius: 3, y: isOn ? 3 : -3)
                    .rotation3DEffect(.degrees(isOn ? -28 : 28), axis: (x: 1, y: 0, z: 0))
                    .offset(y: isOn ? -22 : 22)
            }
        }
    }
}

// MARK: - Rocker

struct RockerSwitchView: View {
    let material: SwitchMaterial
    let colorway: Colorway
    let isOn: Bool

    var body: some View {
        WallPlate(colorway: colorway) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(material.actuatorGradient)
                .frame(width: 84, height: 140)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.black.opacity(0.2), lineWidth: 1)
                )
                .rotation3DEffect(.degrees(isOn ? -9 : 9), axis: (x: 1, y: 0, z: 0),
                                  perspective: 0.6)
                .shadow(color: .black.opacity(0.3), radius: 4, y: isOn ? -3 : 3)
        }
    }
}

// MARK: - Push button

struct PushButtonView: View {
    let material: SwitchMaterial
    let colorway: Colorway
    let isOn: Bool

    var body: some View {
        WallPlate(colorway: colorway, width: 170, height: 230) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.25))
                    .frame(width: 118, height: 118)

                Circle()
                    .fill(material.actuatorGradient)
                    .frame(width: 100, height: 100)
                    .scaleEffect(isOn ? 0.93 : 1.0)
                    .shadow(color: .black.opacity(0.45), radius: isOn ? 2 : 8,
                            y: isOn ? 1 : 5)
                    .overlay(
                        Circle()
                            .fill(isOn ? Color.yellow.opacity(0.55) : Color.black.opacity(0.25))
                            .frame(width: 10, height: 10)
                            .offset(y: -30)
                    )
            }
        }
    }
}

// MARK: - Knife switch

struct KnifeSwitchView: View {
    let material: SwitchMaterial
    let colorway: Colorway
    let isOn: Bool

    var body: some View {
        WallPlate(colorway: colorway, width: 190, height: 250) {
            ZStack {
                // Contact posts
                VStack(spacing: 110) {
                    ContactPost(material: material)
                    ContactPost(material: material)
                }

                // Blade, hinged at the bottom post
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(material.actuatorGradient)
                    .frame(width: 18, height: 130)
                    .overlay(alignment: .top) {
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 22, height: 22)
                            .offset(y: -6)
                    }
                    .offset(y: -55)
                    .rotationEffect(.degrees(isOn ? 0 : 47), anchor: .bottom)
                    .offset(y: 55)
                    .shadow(color: .black.opacity(0.4), radius: 5, y: 4)
            }
        }
    }
}

private struct ContactPost: View {
    let material: SwitchMaterial

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(material.actuatorGradient)
            .frame(width: 34, height: 22)
            .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(.black.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Pull chain

struct PullChainView: View {
    let material: SwitchMaterial
    let colorway: Colorway
    let isOn: Bool

    var body: some View {
        WallPlate(colorway: colorway, width: 150, height: 250) {
            VStack(spacing: 0) {
                // Fixture housing
                Circle()
                    .fill(material.actuatorGradient)
                    .frame(width: 74, height: 74)
                    .overlay(Circle().strokeBorder(.black.opacity(0.25), lineWidth: 1))
                    .shadow(color: .black.opacity(0.3), radius: 4, y: 3)

                // Chain: beads stretch slightly while "pulled" (isOn used only for phase)
                VStack(spacing: isOn ? 3.5 : 3) {
                    ForEach(0..<9, id: \.self) { _ in
                        Circle()
                            .fill(material.actuatorGradient)
                            .frame(width: 8, height: 8)
                    }
                    Capsule()
                        .fill(material.actuatorGradient)
                        .frame(width: 12, height: 26)
                }
                .offset(y: isOn ? 8 : 0)
            }
            .offset(y: -18)
        }
    }
}

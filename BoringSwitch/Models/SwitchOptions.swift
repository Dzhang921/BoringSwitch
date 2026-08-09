import SwiftUI

enum SwitchStyle: String, CaseIterable, Identifiable {
    case toggle, rocker, push, knife, chain

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .toggle: return "Classic Toggle"
        case .rocker: return "Rocker"
        case .push: return "Push Button"
        case .knife: return "Knife Switch"
        case .chain: return "Pull Chain"
        }
    }
}

enum SwitchMaterial: String, CaseIterable, Identifiable {
    case plastic, brass, steel, wood

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .plastic: return "Plastic"
        case .brass: return "Brass"
        case .steel: return "Steel"
        case .wood: return "Wood"
        }
    }

    /// Gradient used for the actuator (the moving part).
    var actuatorGradient: LinearGradient {
        switch self {
        case .plastic:
            return LinearGradient(colors: [Color(white: 0.98), Color(white: 0.82)],
                                  startPoint: .top, endPoint: .bottom)
        case .brass:
            return LinearGradient(colors: [Color(red: 0.95, green: 0.83, blue: 0.55),
                                           Color(red: 0.72, green: 0.55, blue: 0.26)],
                                  startPoint: .top, endPoint: .bottom)
        case .steel:
            return LinearGradient(colors: [Color(white: 0.92), Color(white: 0.55),
                                           Color(white: 0.75)],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        case .wood:
            return LinearGradient(colors: [Color(red: 0.62, green: 0.44, blue: 0.28),
                                           Color(red: 0.42, green: 0.28, blue: 0.16)],
                                  startPoint: .top, endPoint: .bottom)
        }
    }
}

enum Colorway: String, CaseIterable, Identifiable {
    case white, charcoal, cream, sage, rose, sky, lavender, butter

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .white: return "Cloud White"
        case .charcoal: return "Charcoal"
        case .cream: return "Cream"
        case .sage: return "Sage"
        case .rose: return "Dusty Rose"
        case .sky: return "Sky"
        case .lavender: return "Lavender"
        case .butter: return "Butter"
        }
    }

    var plateColor: Color {
        switch self {
        case .white: return Color(red: 0.96, green: 0.96, blue: 0.95)
        case .charcoal: return Color(red: 0.22, green: 0.22, blue: 0.24)
        case .cream: return Color(red: 0.95, green: 0.91, blue: 0.82)
        case .sage: return Color(red: 0.72, green: 0.78, blue: 0.68)
        case .rose: return Color(red: 0.86, green: 0.72, blue: 0.72)
        case .sky: return Color(red: 0.68, green: 0.79, blue: 0.88)
        case .lavender: return Color(red: 0.76, green: 0.72, blue: 0.86)
        case .butter: return Color(red: 0.95, green: 0.89, blue: 0.63)
        }
    }

    /// Detail color (screws, engravings) that stays visible on the plate.
    var detailColor: Color {
        self == .charcoal ? Color(white: 0.55) : Color(white: 0.35).opacity(0.6)
    }
}

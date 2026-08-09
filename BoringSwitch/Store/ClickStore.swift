import Foundation
import Combine

/// Tracks the lifetime click count and the small statistics that make
/// pressing a light switch feel like an accomplishment.
@MainActor
final class ClickStore: ObservableObject {
    @Published private(set) var lifetimeClicks: Int
    @Published private(set) var todayClicks: Int
    @Published private(set) var bestDayClicks: Int
    @Published private(set) var streakDays: Int
    @Published private(set) var firstClickDate: Date?

    private let defaults = UserDefaults.standard
    private var todayKey: String
    private var lastClickDay: Date?

    private static let milestones: [Int: String] = [
        10: "Ten clicks. A promising start to nothing.",
        100: "One hundred clicks. The switch remains unimpressed.",
        500: "Five hundred. It still just turns the light on and off.",
        1_000: "One thousand clicks. Still just a light switch.",
        5_000: "Five thousand. The switch has seen things.",
        10_000: "Ten thousand. Consider going outside.",
        50_000: "Fifty thousand. The switch is worried about you.",
        100_000: "One hundred thousand. This is your life now.",
        1_000_000: "One million clicks. We're legally required to say congratulations.",
    ]

    init() {
        lifetimeClicks = defaults.integer(forKey: "lifetimeClicks")
        bestDayClicks = defaults.integer(forKey: "bestDayClicks")
        streakDays = defaults.integer(forKey: "streakDays")
        firstClickDate = defaults.object(forKey: "firstClickDate") as? Date
        lastClickDay = defaults.object(forKey: "lastClickDay") as? Date

        let today = Calendar.current.startOfDay(for: Date())
        todayKey = "clicks-\(today.timeIntervalSince1970)"
        todayClicks = defaults.integer(forKey: todayKey)
    }

    var averagePerDay: Int {
        guard let first = firstClickDate else { return 0 }
        let days = max(1, Calendar.current.dateComponents([.day], from: first, to: Date()).day! + 1)
        return lifetimeClicks / days
    }

    /// Registers one click and returns a milestone message if one was just crossed.
    func registerClick() -> String? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Roll the daily counter if the app stayed open past midnight.
        let currentKey = "clicks-\(today.timeIntervalSince1970)"
        if currentKey != todayKey {
            todayKey = currentKey
            todayClicks = 0
        }

        if firstClickDate == nil {
            firstClickDate = Date()
            defaults.set(firstClickDate, forKey: "firstClickDate")
        }

        // Streak: consecutive calendar days with at least one click.
        if let last = lastClickDay {
            let gap = calendar.dateComponents([.day], from: last, to: today).day ?? 0
            if gap == 1 { streakDays += 1 } else if gap > 1 { streakDays = 1 }
        } else {
            streakDays = 1
        }
        lastClickDay = today

        lifetimeClicks += 1
        todayClicks += 1
        bestDayClicks = max(bestDayClicks, todayClicks)

        defaults.set(lifetimeClicks, forKey: "lifetimeClicks")
        defaults.set(todayClicks, forKey: todayKey)
        defaults.set(bestDayClicks, forKey: "bestDayClicks")
        defaults.set(streakDays, forKey: "streakDays")
        defaults.set(lastClickDay, forKey: "lastClickDay")

        return Self.milestones[lifetimeClicks]
    }
}

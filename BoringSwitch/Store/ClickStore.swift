import Foundation
import Combine
import WidgetKit

/// Tracks the lifetime click count and the small statistics that make
/// pressing a light switch feel like an accomplishment.
///
/// Data lives in the app-group container so the home screen widget can
/// read it too.
@MainActor
final class ClickStore: ObservableObject {
    static let appGroupSuite = "group.com.boringswitch.app"

    @Published private(set) var lifetimeClicks: Int
    @Published private(set) var todayClicks: Int
    @Published private(set) var bestDayClicks: Int
    @Published private(set) var streakDays: Int
    @Published private(set) var firstClickDate: Date?
    @Published private(set) var rareEventsSeen: Int

    private let defaults: UserDefaults
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
        let shared = UserDefaults(suiteName: Self.appGroupSuite) ?? .standard
        defaults = shared

        // One-time migration from the pre-widget standard container.
        let standard = UserDefaults.standard
        if shared.integer(forKey: "lifetimeClicks") == 0,
           standard.integer(forKey: "lifetimeClicks") > 0 {
            for key in ["lifetimeClicks", "bestDayClicks", "streakDays", "rareEventsSeen"] {
                shared.set(standard.integer(forKey: key), forKey: key)
            }
            for key in ["firstClickDate", "lastClickDay"] {
                shared.set(standard.object(forKey: key), forKey: key)
            }
        }

        lifetimeClicks = shared.integer(forKey: "lifetimeClicks")
        bestDayClicks = shared.integer(forKey: "bestDayClicks")
        streakDays = shared.integer(forKey: "streakDays")
        rareEventsSeen = shared.integer(forKey: "rareEventsSeen")
        firstClickDate = shared.object(forKey: "firstClickDate") as? Date
        lastClickDay = shared.object(forKey: "lastClickDay") as? Date

        let today = Calendar.current.startOfDay(for: Date())
        todayKey = "clicks-\(today.timeIntervalSince1970)"
        todayClicks = shared.integer(forKey: todayKey)
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

        let milestone = Self.milestones[lifetimeClicks]
        if milestone != nil {
            WidgetCenter.shared.reloadTimelines(ofKind: "LifetimeClicks")
        }
        return milestone
    }

    func registerRareEvent() {
        rareEventsSeen += 1
        defaults.set(rareEventsSeen, forKey: "rareEventsSeen")
    }
}

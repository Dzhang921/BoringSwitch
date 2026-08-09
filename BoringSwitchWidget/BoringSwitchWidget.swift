import WidgetKit
import SwiftUI

private let appGroupSuite = "group.com.boringswitch.app"

struct ClickEntry: TimelineEntry {
    let date: Date
    let lifetime: Int
    let today: Int
    let streak: Int
}

struct ClickProvider: TimelineProvider {
    private func currentEntry() -> ClickEntry {
        let defaults = UserDefaults(suiteName: appGroupSuite)
        let today = Calendar.current.startOfDay(for: Date())
        return ClickEntry(
            date: Date(),
            lifetime: defaults?.integer(forKey: "lifetimeClicks") ?? 0,
            today: defaults?.integer(forKey: "clicks-\(today.timeIntervalSince1970)") ?? 0,
            streak: defaults?.integer(forKey: "streakDays") ?? 0
        )
    }

    func placeholder(in context: Context) -> ClickEntry {
        ClickEntry(date: Date(), lifetime: 12847, today: 42, streak: 7)
    }

    func getSnapshot(in context: Context, completion: @escaping (ClickEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClickEntry>) -> Void) {
        // The app reloads timelines on every backgrounding; the hourly refresh
        // only exists to roll the "today" count past midnight.
        completion(Timeline(entries: [currentEntry()],
                            policy: .after(Date().addingTimeInterval(3600))))
    }
}

struct BoringSwitchWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ClickEntry

    var body: some View {
        Group {
            switch family {
            case .systemMedium: medium
            default: small
            }
        }
        .containerBackground(for: .widget) {
            Color(red: 0.07, green: 0.07, blue: 0.09)
        }
    }

    private var small: some View {
        VStack(spacing: 4) {
            Image(systemName: "lightswitch.on")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("\(entry.lifetime)")
                .font(.system(size: 34, weight: .light, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text("lifetime clicks")
                .font(.caption2.smallCaps())
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(Color(white: 0.9))
    }

    private var medium: some View {
        HStack(spacing: 20) {
            VStack(spacing: 2) {
                Text("\(entry.lifetime)")
                    .font(.system(size: 40, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text("lifetime clicks")
                    .font(.caption.smallCaps())
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 10) {
                statLine(value: entry.today, label: "today")
                statLine(value: entry.streak, label: "day streak")
            }
        }
        .foregroundStyle(Color(white: 0.9))
        .padding(.horizontal, 4)
    }

    private func statLine(value: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(value)")
                .font(.system(.title3, design: .rounded).weight(.medium))
                .monospacedDigit()
            Text(label)
                .font(.caption2.smallCaps())
                .foregroundStyle(.secondary)
        }
    }
}

@main
struct BoringSwitchWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LifetimeClicks", provider: ClickProvider()) { entry in
            BoringSwitchWidgetView(entry: entry)
        }
        .configurationDisplayName("Lifetime Clicks")
        .description("Your life's work, at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

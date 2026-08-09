import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var clickStore: ClickStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    statRow("Lifetime clicks", "\(clickStore.lifetimeClicks)")
                    statRow("Today", "\(clickStore.todayClicks)")
                    statRow("Best day", "\(clickStore.bestDayClicks)")
                    statRow("Day streak", "\(clickStore.streakDays)")
                    statRow("Average per day", "\(clickStore.averagePerDay)")
                    if let first = clickStore.firstClickDate {
                        statRow("Clicking since", first.formatted(date: .abbreviated, time: .omitted))
                    }
                    if clickStore.rareEventsSeen > 0 {
                        statRow("Strange occurrences", "\(clickStore.rareEventsSeen)")
                    }
                }

                Section {
                    ShareLink(
                        item: CertificateView.renderImage(clicks: clickStore.lifetimeClicks,
                                                          since: clickStore.firstClickDate),
                        preview: SharePreview(
                            "Certificate of Dedication",
                            image: CertificateView.renderImage(clicks: clickStore.lifetimeClicks,
                                                               since: clickStore.firstClickDate))
                    ) {
                        Label("Share Certificate of Dedication", systemImage: "rosette")
                    }
                } footer: {
                    Text("Proof of your commitment, suitable for framing.")
                }

                Section {
                    EmptyView()
                } footer: {
                    Text("Every click is counted. None of them matter.")
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}

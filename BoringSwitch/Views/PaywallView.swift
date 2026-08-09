import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var premiumStore: PremiumStore
    @Environment(\.dismiss) private var dismiss
    @State private var isWorking = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Spacer()

                Image(systemName: "lightswitch.on")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(.tint)

                Text("Boring Switch Premium")
                    .font(.title2.weight(.semibold))

                VStack(alignment: .leading, spacing: 14) {
                    featureRow("lightswitch.on", "All 5 switch styles")
                    featureRow("cube", "All 4 materials, each with its own click")
                    featureRow("paintpalette", "All 8 wall plate colors")
                    featureRow("infinity", "One purchase. Yours for life. No subscription.")
                }
                .padding(.horizontal, 8)

                if premiumStore.isTrialActive {
                    Text("Your free trial has \(premiumStore.trialDaysRemaining) day\(premiumStore.trialDaysRemaining == 1 ? "" : "s") left.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else if !premiumStore.isPurchased {
                    Text("Your free trial has ended.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if premiumStore.isPurchased {
                    Label("You own Premium. Forever.", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                } else {
                    Button {
                        isWorking = true
                        Task {
                            await premiumStore.purchase()
                            isWorking = false
                            if premiumStore.isPurchased { dismiss() }
                        }
                    } label: {
                        Text("Unlock forever · \(premiumStore.priceText)")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isWorking)

                    Button("Restore Purchases") {
                        Task { await premiumStore.restorePurchases() }
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(24)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Purchase Failed", isPresented: .init(
                get: { premiumStore.purchaseError != nil },
                set: { if !$0 { premiumStore.purchaseError = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(premiumStore.purchaseError ?? "")
            }
        }
    }

    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 26)
                .foregroundStyle(.tint)
            Text(text)
        }
        .font(.subheadline)
    }
}

import SwiftUI

struct CustomizeView: View {
    @Binding var styleRaw: String
    @Binding var materialRaw: String
    @Binding var colorwayRaw: String
    @Binding var showPaywall: Bool

    @EnvironmentObject private var premiumStore: PremiumStore
    @Environment(\.dismiss) private var dismiss

    private var style: SwitchStyle { SwitchStyle(rawValue: styleRaw) ?? .toggle }
    private var material: SwitchMaterial { SwitchMaterial(rawValue: materialRaw) ?? .plastic }
    private var colorway: Colorway { Colorway(rawValue: colorwayRaw) ?? .white }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Spacer()
                        SwitchAssemblyView(style: style, material: material,
                                           colorway: colorway, isOn: true, flip: {})
                            .scaleEffect(0.62)
                            .frame(height: 170)
                            .allowsHitTesting(false)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }

                Section("Style") {
                    ForEach(SwitchStyle.allCases) { option in
                        optionRow(name: option.displayName, isFree: option.isFree,
                                  isSelected: option == style) {
                            styleRaw = option.rawValue
                        }
                    }
                }

                Section("Material") {
                    ForEach(SwitchMaterial.allCases) { option in
                        optionRow(name: option.displayName, isFree: option.isFree,
                                  isSelected: option == material) {
                            materialRaw = option.rawValue
                        }
                    }
                }

                Section("Color") {
                    ForEach(Colorway.allCases) { option in
                        optionRow(name: option.displayName, isFree: option.isFree,
                                  isSelected: option == colorway,
                                  swatch: option.plateColor) {
                            colorwayRaw = option.rawValue
                        }
                    }
                }

                if !premiumStore.isPurchased {
                    Section {
                        Button {
                            showPaywall = true
                            dismiss()
                        } label: {
                            Text("Unlock everything forever · \(premiumStore.priceText)")
                        }
                        .font(.subheadline.weight(.medium))
                    }
                }
            }
            .navigationTitle("Customize")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func optionRow(name: String, isFree: Bool, isSelected: Bool,
                           swatch: Color? = nil, select: @escaping () -> Void) -> some View {
        let locked = !isFree && !premiumStore.isPremiumActive
        Button {
            if locked {
                showPaywall = true
                dismiss()
            } else {
                select()
            }
        } label: {
            HStack {
                if let swatch {
                    Circle()
                        .fill(swatch)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().strokeBorder(.black.opacity(0.15), lineWidth: 1))
                }
                Text(name)
                    .foregroundStyle(locked ? .secondary : .primary)
                Spacer()
                if locked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                }
            }
        }
    }
}

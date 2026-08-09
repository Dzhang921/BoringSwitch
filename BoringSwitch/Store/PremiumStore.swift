import Foundation
import StoreKit

/// Premium unlock: $0.99 lifetime non-consumable. No subscription, no trial.
@MainActor
final class PremiumStore: ObservableObject {
    static let productID = "com.boringswitch.lifetime"

    @Published private(set) var isPurchased: Bool
    @Published private(set) var product: Product?
    @Published var purchaseError: String?

    private let defaults = UserDefaults.standard
    private var updatesTask: Task<Void, Never>?

    init() {
        isPurchased = defaults.bool(forKey: "premiumPurchased")
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                if let transaction = try? update.payloadValue {
                    await self?.handle(transaction: transaction)
                }
            }
        }
        Task {
            await loadProduct()
            await refreshEntitlements()
        }
    }

    deinit { updatesTask?.cancel() }

    /// True while premium content should be usable.
    var isPremiumActive: Bool { isPurchased }

    var priceText: String { product?.displayPrice ?? "$0.99" }

    // MARK: - StoreKit

    func loadProduct() async {
        do {
            product = try await Product.products(for: [Self.productID]).first
        } catch {
            purchaseError = nil // No store connection; the UI falls back to a static price.
        }
    }

    func purchase() async {
        guard let product else {
            purchaseError = "The App Store product isn't available right now. Try again later."
            return
        }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try verification.payloadValue
                await handle(transaction: transaction)
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    private func refreshEntitlements() async {
        for await entitlement in Transaction.currentEntitlements {
            if let transaction = try? entitlement.payloadValue {
                await handle(transaction: transaction)
            }
        }
    }

    private func handle(transaction: Transaction) async {
        guard transaction.productID == Self.productID else { return }
        if transaction.revocationDate == nil {
            isPurchased = true
            defaults.set(true, forKey: "premiumPurchased")
        } else {
            isPurchased = false
            defaults.set(false, forKey: "premiumPurchased")
        }
        await transaction.finish()
    }
}

import Foundation
import StoreKit

protocol MonetizationClient {
    var isEnabled: Bool { get }
    func catalog() async -> [StoreProduct]
}

struct DisabledMonetizationClient: MonetizationClient {
    let isEnabled = false

    func catalog() async -> [StoreProduct] {
        [
            StoreProduct(
                id: "perfectstack.themepack.launch",
                kind: .themePack,
                displayName: "Theme Pack",
                description: "Future cosmetic pack with new tower palettes.",
                isEnabled: false
            ),
            StoreProduct(
                id: "perfectstack.fxpack.launch",
                kind: .fxPack,
                displayName: "Effects Pack",
                description: "Future premium visual effect set.",
                isEnabled: false
            ),
            StoreProduct(
                id: "perfectstack.adfree.launch",
                kind: .adFree,
                displayName: "Ad-Free",
                description: "Future ad-free entitlement.",
                isEnabled: false
            )
        ]
    }
}


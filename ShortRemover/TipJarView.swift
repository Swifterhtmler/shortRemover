//
//  Tipjarview.swift
//  ShortRemover
//
//  Created by Riku Kuisma on 5.4.2026.
//

import SwiftUI
import StoreKit
import Combine

// MARK: - Tip Store
@MainActor
class TipStore: ObservableObject {
    @Published var product: Product?
    @Published var isPurchasing = false
    @Published var didTip = false
    @Published var errorMessage: String?

    // ⚠️ Replace with your actual product ID from App Store Connect
    let productID = "shortremover.ShortRemover.tip"

    init() {
        Task { await fetchProduct() }
    }

    func fetchProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            self.product = products.first
        } catch {
            self.errorMessage = "Couldn't load tip option."
        }
    }

    func purchase() async {
        guard let product else { return }
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success:
                didTip = true
            case .userCancelled:
                break
            default:
                errorMessage = "Something went wrong. Try again!"
            }
        } catch {
            errorMessage = "Purchase failed. Try again!"
        }
    }
}

// MARK: - Tip Jar View
struct TipJarView: View {
    @StateObject private var store = TipStore()

    var body: some View {
        VStack(spacing: 20) {
            if store.didTip {
                // Thank you state
                VStack(spacing: 8) {
                    Text("❤️")
                        .font(.system(size: 44))
                    Text("Thank you!")
                        .font(.headline)
                    Text("You're awesome. Enjoy Shorts-free YouTube.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                // Default state
                VStack(spacing: 8) {
                    Text("☕️")
                        .font(.system(size: 44))
                    Text("Enjoying ShortRemover?")
                        .font(.headline)
                    Text("It's free and always will be. But if it saves you time, a small tip keeps development going.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if let product = store.product {
                    Button {
                        Task { await store.purchase() }
                    } label: {
                        HStack {
                            if store.isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Buy me a coffee — \(product.displayPrice)")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(store.isPurchasing)
                } else if store.errorMessage == nil {
                    ProgressView()
                }

                if let error = store.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
    }
}


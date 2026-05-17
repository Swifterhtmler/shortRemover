//
//  TipJarView.swift
//  ShortRemover
//
//  Created by Riku Kuisma on 13.5.2026.
//

import AppKit
import SwiftUI
import StoreKit
import Combine

extension Notification.Name {
    static let tipPurchaseSucceeded = Notification.Name("tipPurchaseSucceeded")
}

enum TipTransactionListener {
    private static var updatesTask: Task<Void, Never>?

    static func start() {
        guard updatesTask == nil else { return }
        updatesTask = Task(priority: .background) {
            for await update in StoreKit.Transaction.updates {
                await handle(update)
            }
        }
    }

    @MainActor
    private static func handle(_ update: VerificationResult<StoreKit.Transaction>) async {
        guard case .verified(let transaction) = update else { return }
        guard transaction.productID == TipStore.productID else {
            await transaction.finish()
            return
        }
        NotificationCenter.default.post(name: .tipPurchaseSucceeded, object: nil)
        await transaction.finish()
    }
}

enum TipJarPresenter {
    private static var panel: NSPanel?
    private static var panelDelegate: PanelDelegate?

    private static let panelSize = NSSize(width: 420, height: 440)

    @MainActor
    static func show(from viewController: NSViewController? = nil) {
        if let panel {
            panel.makeKeyAndOrderFront(nil)
            return
        }

        let parentWindow = viewController?.view.window ?? NSApp.keyWindow

        let delegate = PanelDelegate { close() }
        panelDelegate = delegate

        let hosting = NSHostingController(rootView: TipJarView(onDismiss: close))
        hosting.preferredContentSize = panelSize

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: panelSize),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        panel.title = "Support ShortRemover"
        panel.contentViewController = hosting
        panel.delegate = delegate
        panel.isReleasedWhenClosed = false
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true

        if let parentWindow {
            panel.center(in: parentWindow)
        } else {
            panel.center()
        }

        panel.makeKeyAndOrderFront(nil)
        self.panel = panel
    }

    @MainActor
    static func close() {
        guard let panel else { return }
        panel.delegate = nil
        panel.orderOut(nil)
        self.panel = nil
        panelDelegate = nil
    }

    private final class PanelDelegate: NSObject, NSWindowDelegate {
        let onClose: () -> Void

        init(onClose: @escaping () -> Void) {
            self.onClose = onClose
        }

        func windowWillClose(_ notification: Notification) {
            onClose()
        }
    }
}

private extension NSPanel {
    func center(in parent: NSWindow) {
        let parentFrame = parent.frame
        var frame = self.frame
        frame.origin.x = parentFrame.midX - frame.width / 2
        frame.origin.y = parentFrame.midY - frame.height / 2
        setFrame(frame, display: true)
    }
}

// MARK: - Tip Store

@MainActor
class TipStore: ObservableObject {
    static let productID = "shortremover.ShortRemover.tip"

    @Published var product: Product?
    @Published var isPurchasing = false
    @Published var didTip = false
    @Published var errorMessage: String?

    private var purchaseObserver: NSObjectProtocol?

    init() {
        Task { await fetchProduct() }
        purchaseObserver = NotificationCenter.default.addObserver(
            forName: .tipPurchaseSucceeded,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.didTip = true
            }
        }
    }

    deinit {
        if let purchaseObserver {
            NotificationCenter.default.removeObserver(purchaseObserver)
        }
    }

    func fetchProduct() async {
        do {
            let products = try await Product.products(for: [Self.productID])
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
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    didTip = true
                    await transaction.finish()
                case .unverified:
                    errorMessage = "Purchase could not be verified."
                }
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
    let onDismiss: () -> Void

    @StateObject private var store = TipStore()

    var body: some View {
        VStack(spacing: 20) {
            if store.didTip {
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
                VStack(spacing: 8) {
                    Text("☕️")
                        .font(.system(size: 44))
                    Text("Enjoying ShortRemover?")
                        .font(.headline)
                    Text("It's free and always will be. But if it saves you time, a small tip keeps development going.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
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
                    .buttonStyle(.plain)
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

            Button("Not now") {
                onDismiss()
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(width: 420, height: 440)
    }
}

import Foundation
import WebKit
import SwiftUI

final class WebController: NSObject, WKScriptMessageHandler {
    let webView: WKWebView

    override init() {
        let userContent = WKUserContentController()
        let config = WKWebViewConfiguration()
        config.userContentController = userContent

        // Initialize stored properties before calling super.init()
        self.webView = WKWebView(frame: .zero, configuration: config)

        // Now it's safe to call super and reference self
        super.init()

        // Register the handler name to match the HTML: webkit.messageHandlers.controller.postMessage('tip')
        userContent.add(self, name: "controller")

        loadMainHTML()
    }

    private func loadMainHTML() {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "html") else { return }
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "controller" else { return }
        print("WKMessage received:", message.body)
        if let command = message.body as? String, command == "tip" {
            DispatchQueue.main.async {
                TipJarPresenter.show()
            }
        } else {
            print("Unexpected message body:", message.body)
        }
    }
}

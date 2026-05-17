//
//  ViewController.swift
//  ShortRemover
//
//  Created by Riku Kuisma on 9.4.2026.
//

import AppKit
import WebKit
import SwiftUI

class ViewController: NSViewController, WKNavigationDelegate, WKScriptMessageHandler {

    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.configuration.userContentController.add(self, name: "controller")
        webView.navigationDelegate = self

        if let url = Bundle.main.url(forResource: "Main", withExtension: "html"),
           let resourceURL = Bundle.main.resourceURL {
            webView.loadFileURL(url, allowingReadAccessTo: resourceURL)
        }
    }

    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard let body = message.body as? String, body == "tip" else { return }
        TipJarPresenter.show(from: self)
    }
}

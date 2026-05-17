import Cocoa
import WebKit

final class MainWindowController: NSWindowController {
    private let webController = WebController()

    convenience init() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 480, height: 640),
                              styleMask: [.titled, .closable, .miniaturizable, .resizable],
                              backing: .buffered,
                              defer: false)
        self.init(window: window)
        window.title = "ShortRemover"
        window.center()
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        guard let contentView = window?.contentView else { return }
        let wk = webController.webView
        wk.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wk)
        NSLayoutConstraint.activate([
            wk.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            wk.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            wk.topAnchor.constraint(equalTo: contentView.topAnchor),
            wk.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

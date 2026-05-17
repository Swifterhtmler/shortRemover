//
//  AppDelegate.swift
//  ShortRemover
//
//  Created by Riku Kuisma on 9.4.2026.
//

import AppKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        TipTransactionListener.start()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

//
//  AppDelegate.swift
//  barber
//
//  Created by Max Ainatchi on 7/18/20.
//  Copyright © 2020 Max Ainatchi, Inc. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let size = NSSize(width: 400, height: 400)
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.contentSize = size
        popover.behavior = .transient
        return popover
    }()

    lazy var statusBarItem: NSStatusItem = {
        let statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        statusBarItem.button?.image = NSImage(named: "icon")
        return statusBarItem
    }()

    var state = BackgroundScheduledLoadState(interval: 10 ... 20, load: Homebrew.shared.outdated)

    func applicationDidFinishLaunching(_: Notification) {
        let contentView = ContentView(state: self.state, size: self.size)
        self.popover.contentViewController = NSHostingController(rootView: contentView)

        self.statusBarItem.button?.action = #selector(self.togglePopover(_:))

        self.state.reload()
        self.state.schedule()
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = self.statusBarItem.button else { return }
        if self.popover.isShown {
            self.popover.performClose(sender)
        } else {
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
            self.popover.contentViewController?.view.window?.becomeKey()
            self.state.refreshIfNeeded()
        }
    }
}

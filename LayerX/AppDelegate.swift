//
//  AppDelegate.swift
//  LayerX
//
//  Created by Michael Chen on 2015/10/26.
//  Copyright © 2015年 Michael Chen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	weak var window: NSWindow?
	func applicationDidFinishLaunching(aNotification: NSNotification) {
		if let window = NSApp.windows.first {
			window.styleMask = NSBorderlessWindowMask | NSResizableWindowMask
			window.opaque = false
			window.backgroundColor = NSColor.clearColor()
			window.movableByWindowBackground = true
			window.hasShadow = false
			self.window = window

			adjustWindowToMiniumSize(NSMakeSize(480, 320))
		}
	}

	func adjustWindowToMiniumSize(size: NSSize) {
		guard let window = window else { return }

		var frame = window.frame
		if frame.size.width < size.width || frame.size.height < size.height {
			frame.size = size
			window.setFrame(frame, display: true)
		}
	}
}

// MARK: - Helper

func appDelegate() -> AppDelegate {
	return NSApp.delegate as! AppDelegate
}


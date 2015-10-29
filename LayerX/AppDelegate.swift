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

	weak var window: MCWIndow!
	weak var viewController: ViewController!

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		if let window = NSApp.windows.first as? MCWIndow {
			window.fitsWithSize(NSMakeSize(480, 320))
			self.window = window
		}
	}
}

// MARK: - Hotkeys

extension AppDelegate {

	@IBAction func actualSize(sender: AnyObject?) {
		let image = viewController.imageView.image!
		window.resizeTo(image.size, animated: true)
	}

	@IBAction func makeLarger(sender: AnyObject) {
		var size = window.frame.size
		size = size * 1.1
		window.resizeTo(size, animated: true)
	}

	@IBAction func makeSmaller(sender: AnyObject) {
		var size = window.frame.size
		size = size * 0.9
		window.resizeTo(size, animated: true)
	}

	@IBAction func increaseTransparency(sender: AnyObject) {
		var alpha = viewController.imageView.alphaValue
		alpha -= 0.1
		viewController.imageView.alphaValue = max(alpha, 0.05)
	}

	@IBAction func reduceTransparency(sender: AnyObject) {
		var alpha = viewController.imageView.alphaValue
		alpha += 0.1
		viewController.imageView.alphaValue = min(alpha, 1.0)
	}

	
	@IBAction func toggleLockWindow(sender: AnyObject) {
		let menuItem = sender as! NSMenuItem
		if menuItem.title == "Lock" {
			menuItem.title  = "Unlock"
			window.movable = false
		} else {
			menuItem.title  = "Lock"
			window.movable = true
		}

		viewController.lockIconImageView.hidden = window.movable
	}

	override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
		return viewController.imageView.image != nil
	}
}

// MARK: - Helper

func appDelegate() -> AppDelegate {
	return NSApp.delegate as! AppDelegate
}

func *(size: NSSize, scale: CGFloat) -> NSSize {
	return NSMakeSize(size.width * scale, size.height * scale)
}
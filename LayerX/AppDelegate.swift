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

	private let defaultSize = NSMakeSize(480, 320)
	private let resizeStep: CGFloat = 0.1

	var allSpaces = false
	var locked = false
	var onTop = false

	weak var window: MCWIndow!
	weak var viewController: ViewController!
	var isLockIconHiddenWhileLocked = false {
		didSet { viewController.lockIconImageView.isHidden = window.isMovable || isLockIconHiddenWhileLocked }
	}
	var isSizeHidden = false {
		didSet { viewController.sizeTextField.isHidden = isSizeHidden }
	}

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		if let window = NSApp.windows.first as? MCWIndow {
			window.fitsWithSize(defaultSize)
			window.collectionBehavior = [.managed, .moveToActiveSpace]
			self.window = window
		}
	}
}

fileprivate enum ArrowTag: Int {
	case up = 20
	case left = 21
	case right = 22
	case down = 23
}

// MARK: - Hotkeys

extension AppDelegate {

	private var originalSize: NSSize {
		viewController.imageView.image?.size ?? defaultSize
	}

	private func resizeAspectFit(calculator: (_ original: CGFloat, _ current: CGFloat) -> CGFloat) {
		let originalSize = self.originalSize
		let width = calculator(originalSize.width, window.frame.size.width)
		let height = width / originalSize.width * originalSize.height

		if width > 0 {
			window.resizeTo(NSSize(width: width, height: height), animated: true)
		}
	}

	@IBAction func actualSize(_ sender: AnyObject?) {
		window.resizeTo(originalSize, animated: true)
	}

	@IBAction func makeLarger(_ sender: AnyObject) {
		resizeAspectFit { $0 * ($1 / $0 + resizeStep) }
	}

	@IBAction func makeSmaller(_ sender: AnyObject) {
		resizeAspectFit { $0 * ($1 / $0 - resizeStep) }
	}

	@IBAction func makeLargerOnePixel(_ sender: AnyObject) {
		resizeAspectFit { $1 + 1 }
	}

	@IBAction func makeSmallerOnePixel(_ sender: AnyObject) {
		resizeAspectFit { $1 - 1 }
	}

	@IBAction func increaseTransparency(_ sender: AnyObject) {
		var alpha = viewController.imageView.alphaValue
		alpha -= 0.1
		viewController.imageView.alphaValue = max(alpha, 0.05)
	}

	@IBAction func reduceTransparency(_ sender: AnyObject) {
		var alpha = viewController.imageView.alphaValue
		alpha += 0.1
		viewController.imageView.alphaValue = min(alpha, 1.0)
	}
	
	func getPasteboardImage() -> NSImage? {
		let pasteboard = NSPasteboard.general;
		if let file = pasteboard.data(forType: NSPasteboard.PasteboardType.fileURL),
		   let str = String(data: file, encoding: .utf8),
		   let url = URL(string: str)
		{
			return NSImage(contentsOf: url)
		}

		if let tiff = pasteboard.data(forType: NSPasteboard.PasteboardType.tiff) {
			return NSImage(data: tiff)
		}

		if let png = pasteboard.data(forType: NSPasteboard.PasteboardType.png) {
			return NSImage(data: png)
		}

		return nil
	}
	
	@IBAction func paste(_ sender: AnyObject) {
		guard let image = getPasteboardImage() else { return }
		let rep = image.representations[0]
		viewController.imageView.image = image
		let size = NSMakeSize(CGFloat(rep.pixelsWide), CGFloat(rep.pixelsHigh))
		window.resizeTo(size, animated: true)
		viewController.sizeTextField.isHidden = false
		viewController.placeholderTextField.isHidden = true

	}
	
	@IBAction func toggleLockWindow(_ sender: AnyObject) {
		let menuItem = sender as! NSMenuItem
		locked = !locked
		onTop = locked
		if locked {
			menuItem.title  = "Unlock"
			window.isMovable = false
			window.ignoresMouseEvents = true
			window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
		} else {
			menuItem.title  = "Lock"
			window.isMovable = true
			window.ignoresMouseEvents = false
			window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.normalWindow)))
		}

		viewController.lockIconImageView.isHidden = window.isMovable || isLockIconHiddenWhileLocked
	}
	
	@IBAction func toggleOnTop(_ sender: AnyObject) {
		let menuItem = sender as! NSMenuItem
		onTop = !onTop
		if onTop {
			menuItem.title = "Don't keep on top"
			window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
		} else if !locked {
			menuItem.title = "Keep on top"
			window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.normalWindow)))
		}
	}
	
	@IBAction func toggleLockIconVisibility(_ sender: AnyObject) {
		let menuItem = sender as! NSMenuItem
		menuItem.state = menuItem.state == .on ? .off : .on
		isLockIconHiddenWhileLocked = menuItem.state == .on
	}

	@IBAction func toggleSizeVisibility(_ sender: AnyObject) {
		let menuItem = sender as! NSMenuItem
		menuItem.state = menuItem.state == .on ? .off : .on
		isSizeHidden = menuItem.state == .on
	}

	@IBAction func moveAround(_ sender: AnyObject) {
		let menuItem = sender as! NSMenuItem

		guard let arrow = ArrowTag(rawValue: menuItem.tag) else {
			return
		}

		let offset = menuItem.isAlternate ? 10 : 1

		switch arrow {
		case .up:
			window.moveBy(CGPoint(x: 0, y: offset))
		case .left:
			window.moveBy(CGPoint(x: -offset, y: 0))
		case .right:
			window.moveBy(CGPoint(x: offset, y: 0))
		case .down:
			window.moveBy(CGPoint(x: 0, y: -offset))
		}
	}

	@IBAction func toggleAllSpaces(_ sender: AnyObject) {
		let menuItem = sender as! NSMenuItem
		allSpaces = !allSpaces
		if allSpaces {
			menuItem.title = "Keep on this space"
			window.collectionBehavior = [.canJoinAllSpaces]
		} else {
			menuItem.title = "Keep on all spaces"
			window.collectionBehavior = [.managed, .moveToActiveSpace]
		}
	}

	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		return viewController.imageView.image != nil
	}
}

// MARK: - Helper

func appDelegate() -> AppDelegate {
	return NSApp.delegate as! AppDelegate
}

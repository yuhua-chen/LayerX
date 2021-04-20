//
//  ViewController.swift
//  LayerX
//
//  Created by Michael Chen on 2015/10/26.
//  Copyright © 2015年 Michael Chen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	@IBOutlet private weak var imageView: MCDragAndDropImageView!
	@IBOutlet weak var sizeTextField: NSTextField!
	@IBOutlet weak var placeholderTextField: NSTextField!
	@IBOutlet weak var lockIconImageView: NSImageView!
	@IBOutlet weak var tabTextField: NSTextField!

	var isSizeHidden = false {
		didSet { updateTextFieldVisibility() }
	}

	private var currentTab = 1 // Falls in range 1...9
	private var tabImages = [Int: NSImage]()

	override var acceptsFirstResponder: Bool {
		return true
	}

	lazy var trackingArea: NSTrackingArea = {
		let options: NSTrackingArea.Options = [.activeAlways, .mouseEnteredAndExited, .inVisibleRect]
		return NSTrackingArea(rect: view.bounds, options: options, owner: self, userInfo: nil)
	}()

	private var isMouseInView: Bool {
		guard let window = view.window else { return false }
		return view.isMousePoint(window.mouseLocationOutsideOfEventStream, in: view.frame)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		appDelegate().viewController = self
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		imageView.delegate = self

		sizeTextField.layer?.cornerRadius = 3
		sizeTextField.layer?.masksToBounds = true

		lockIconImageView.wantsLayer = true
		lockIconImageView.layer?.backgroundColor = NSColor(white: 0.0, alpha: 0.5).cgColor
		lockIconImageView.layer?.cornerRadius = 5
		lockIconImageView.layer?.masksToBounds = true

		NotificationCenter.default.addObserver(self, selector: #selector(windowDidResize(_:)), name: NSWindow.didResizeNotification, object: appDelegate().window)

		view.addTrackingArea(trackingArea)

		NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event -> NSEvent? in
			if event.modifierFlags.contains(.command), event.characters?.count == 1 {
				if event.characters?.lowercased() == "w" {
					self?.updateCurrentImage(nil)
					return nil
				} else if let digit = event.characters.flatMap(Int.init), digit != 0 {
					self?.selectTab(digit)
					return nil
				}
			}

			return event
		}
	}

	// MARK: Tabs management

	var imageSize: NSSize? {
		guard let image = imageView.image else { return nil }
		let pixelSize = image.representations.first.map { NSSize(width: $0.pixelsWide, height: $0.pixelsHigh) }
		return pixelSize ?? image.size
	}

	func selectTab(_ tab: Int) {
		currentTab = tab
		tabTextField.stringValue = "⌘ \(tab)"
		showImage(tabImages[currentTab])
	}

	func updateCurrentImage(_ image: NSImage?) {
		tabImages[currentTab] = image
		showImage(image)
	}

	private func showImage(_ image: NSImage?) {
		imageView.image = image

		tabTextField.isHidden = false
		updateTextFieldVisibility()

		tabTextField.fadeIn()
		if !isMouseInView {
			tabTextField.fadeOutAfterDelay()
		}
	}

	private func updateTextFieldVisibility() {
		let hasImage = imageView.image != nil

		sizeTextField.isHidden = !hasImage || isSizeHidden
		placeholderTextField.isHidden = hasImage
	}

	// MARK: Actions

	func changeTransparency(by diff: CGFloat) {
		imageView.alphaValue = min(max(imageView.alphaValue + diff, 0.05), 1.0)
	}

	@objc func windowDidResize(_ notification: Notification) {
		let window = notification.object as! NSWindow
		let size = window.frame.size
		sizeTextField.stringValue = "\(Int(size.width))x\(Int(size.height))"
		sizeTextField.fadeIn()

		if !isMouseInView {
			sizeTextField.fadeOutAfterDelay()
		}
	}

	// MARK: Mouse events

	override func scrollWheel(with theEvent: NSEvent) {
		guard imageView.image != nil else { return }

		let delta = theEvent.deltaY * 0.005
		changeTransparency(by: -delta)
	}

	override func mouseEntered(with theEvent: NSEvent) {
		sizeTextField.fadeIn()
		tabTextField.fadeIn()
	}

	override func mouseExited(with theEvent: NSEvent) {
		sizeTextField.fadeOut()
		tabTextField.fadeOut()
	}
}

// MARK: - MCDragAndDropImageViewDelegate

extension ViewController: MCDragAndDropImageViewDelegate {
	func dragAndDropImageViewDidDrop(_ imageView: MCDragAndDropImageView) {
		updateCurrentImage(imageView.image)

		appDelegate().actualSize(nil)
	}
}

// MARK: - Movable NSView

class MCMovableView: NSView{
	override var mouseDownCanMoveWindow:Bool {
		return true
	}
}

// MARK: - Hiding text

fileprivate extension NSView {

	func fadeIn() {
		NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fadeOut), object: nil)

		layer?.opacity = 1
	}

	@objc func fadeOut() {
		// Fade out is always animated
		let transition = CATransition()
		layer?.add(transition, forKey: "fadeOut")
		layer?.opacity = 0
	}

	func fadeOutAfterDelay() {
		NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fadeOut), object: nil)

		perform(#selector(fadeOut), with: nil, afterDelay: 2)
	}

}

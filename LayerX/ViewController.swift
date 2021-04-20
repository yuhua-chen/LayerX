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

	override var acceptsFirstResponder: Bool {
		return true
	}

	lazy var trackingArea: NSTrackingArea = {
		let options: NSTrackingArea.Options = [.activeAlways, .mouseEnteredAndExited]
		return NSTrackingArea(rect: self.view.bounds, options: options, owner: self, userInfo: nil)
	}()

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
	}

	var imageSize: NSSize? {
		guard let image = imageView.image else { return nil }
		let pixelSize = image.representations.first.map { NSSize(width: $0.pixelsWide, height: $0.pixelsHigh) }
		return pixelSize ?? image.size
	}

	func updateCurrentImage(_ image: NSImage?) {
		imageView.image = image

		sizeTextField.isHidden = image == nil
		placeholderTextField.isHidden = image != nil
	}

	// MARK: Actions

	func changeTransparency(by diff: CGFloat) {
		imageView.alphaValue = min(max(imageView.alphaValue + diff, 0.05), 1.0)
	}

	@objc func fadeOutSizeTextField() {
		let transition = CATransition()
		sizeTextField.layer?.add(transition, forKey: "fadeOut")
		sizeTextField.layer?.opacity = 0
	}

	@objc func windowDidResize(_ notification: Notification) {
		let window = notification.object as! NSWindow
		let size = window.frame.size
		sizeTextField.stringValue = "\(Int(size.width))x\(Int(size.height))"
		sizeTextField.layer?.opacity = 1

		NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ViewController.fadeOutSizeTextField), object: nil)
		perform(#selector(ViewController.fadeOutSizeTextField), with: nil, afterDelay: 2)
	}

	// MARK: Mouse events

	override func scrollWheel(with theEvent: NSEvent) {
		guard imageView.image != nil else { return }

		let delta = theEvent.deltaY * 0.005
		changeTransparency(by: -delta)
	}

	override func mouseEntered(with theEvent: NSEvent) {
		sizeTextField.layer?.opacity = 1
	}

	override func mouseExited(with theEvent: NSEvent) {
		fadeOutSizeTextField()
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

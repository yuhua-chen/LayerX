//
//  MCDragAndDropImageView.swift
//  LayerX
//
//  Created by Michael Chen on 2015/10/26.
//  Copyright © 2015年 Michael Chen. All rights reserved.
//

import Cocoa

protocol MCDragAndDropImageViewDelegate: class {
	func dragAndDropImageViewDidDrop(imageView: MCDragAndDropImageView)
}

class MCDragAndDropImageView: NSImageView {

	weak var delegate: MCDragAndDropImageViewDelegate?

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		registerForDraggedTypes(NSImage.imageTypes())

		wantsLayer = true
	}

	override func setNeedsDisplay() {
		alphaValue = image == nil ? 1.0 : 0.6
		super.setNeedsDisplay()
	}

	override func drawRect(dirtyRect: NSRect) {
		super.drawRect(dirtyRect)
		layer?.backgroundColor = NSColor(white: highlighted ? 0.5 : 0.8, alpha: 1.0).CGColor
	}

	override var mouseDownCanMoveWindow:Bool {
		return true
	}
}

// MARK: - NSDraggingSource

extension MCDragAndDropImageView: NSDraggingSource {

	override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {

		if (NSImage.canInitWithPasteboard(sender.draggingPasteboard())) {
			highlighted = true

			setNeedsDisplay()

			let sourceDragMask = sender.draggingSourceOperationMask()
			let pboard = sender.draggingPasteboard()

			if pboard.availableTypeFromArray([NSFilenamesPboardType]) == NSFilenamesPboardType {
				if sourceDragMask.rawValue & NSDragOperation.Copy.rawValue != 0 {
					return NSDragOperation.Copy
				}
			}
		}

		return .None
	}

	override func draggingExited(sender: NSDraggingInfo?) {
		highlighted = false
		setNeedsDisplay()
	}

	override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
		highlighted = false
		setNeedsDisplay()

		return NSImage.canInitWithPasteboard(sender.draggingPasteboard())
	}

	override func performDragOperation(sender: NSDraggingInfo) -> Bool {
		if (NSImage.canInitWithPasteboard(sender.draggingPasteboard())) {
			image = NSImage(pasteboard: sender.draggingPasteboard())
			delegate?.dragAndDropImageViewDidDrop(self)
			setNeedsDisplay()
		}

		return true
	}

	func draggingSession(session: NSDraggingSession, sourceOperationMaskForDraggingContext context: NSDraggingContext) -> NSDragOperation {
		switch context {
		case .OutsideApplication: return .None
		case .WithinApplication: return .Copy
		}
	}
}
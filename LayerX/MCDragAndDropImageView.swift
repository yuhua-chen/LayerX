//
//  MCDragAndDropImageView.swift
//  LayerX
//
//  Created by Michael Chen on 2015/10/26.
//  Copyright © 2015年 Michael Chen. All rights reserved.
//

import Cocoa

protocol MCDragAndDropImageViewDelegate: class {
	func dragAndDropImageViewDidDrop(_ imageView: MCDragAndDropImageView)
}

class MCDragAndDropImageView: NSImageView {

	weak var delegate: MCDragAndDropImageViewDelegate?

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		register(forDraggedTypes: NSImage.imageTypes())

		wantsLayer = true
	}

	override func setNeedsDisplay() {
		alphaValue = image == nil ? 1.0 : 0.6
		super.setNeedsDisplay()
	}

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		if let _ = image {
			layer?.backgroundColor = NSColor.clear.cgColor
			return
		}

		layer?.backgroundColor = NSColor(white: isHighlighted ? 0.5 : 0.8, alpha: 1.0).cgColor
	}

	override var mouseDownCanMoveWindow:Bool {
		return true
	}
}

// MARK: - NSDraggingSource

extension MCDragAndDropImageView: NSDraggingSource {

	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {

		if (NSImage.canInit(with: sender.draggingPasteboard())) {
			isHighlighted = true

			setNeedsDisplay()

			let sourceDragMask = sender.draggingSourceOperationMask()
			let pboard = sender.draggingPasteboard()

			if pboard.availableType(from: [NSFilenamesPboardType]) == NSFilenamesPboardType {
				if sourceDragMask.rawValue & NSDragOperation.copy.rawValue != 0 {
					return NSDragOperation.copy
				}
			}
		}

		return NSDragOperation()
	}

	override func draggingExited(_ sender: NSDraggingInfo?) {
		isHighlighted = false
		setNeedsDisplay()
	}

	override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
		isHighlighted = false
		setNeedsDisplay()

		return NSImage.canInit(with: sender.draggingPasteboard())
	}

	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		if (NSImage.canInit(with: sender.draggingPasteboard())) {
			image = NSImage(pasteboard: sender.draggingPasteboard())
			delegate?.dragAndDropImageViewDidDrop(self)
			setNeedsDisplay()
		}

		return true
	}

	func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
		switch context {
		case .outsideApplication: return NSDragOperation()
		case .withinApplication: return .copy
		}
	}
}

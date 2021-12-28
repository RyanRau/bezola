//
//  ClickableTextField.swift
//  bezola
//
//  Created by Ryan Rau on 12/28/21.
//

import Cocoa

class ClickableTextField: NSTextField {
    var onClickCallback : (() -> Void)? = nil
    
    override func mouseDown(with event: NSEvent) {
        self.sendAction(#selector(didClick(_:)), to: self)
        super.mouseDown(with: event)
    }

    @objc func didClick(_ event: NSEvent) {
        guard let callback = onClickCallback else { return }
        callback()
    }
}

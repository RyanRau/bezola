//
//  SongTableCellViewController.swift
//  bezola
//
//  Created by Ryan Rau on 12/8/21.
//

import Foundation
import Cocoa

class SongTableCell: NSView {
    
    @IBOutlet weak var track: NSTextField!
    @IBOutlet weak var artist: NSTextField!
    @IBOutlet weak var year: NSTextField!
    @IBOutlet weak var albumArt: NSImageView!
    
    var mainView: NSView?
    
    init() {
        super.init(frame: NSRect.zero)
        _ = load(fromNIBNamed: "SongTableCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadImage(url: String) {
        Helpers.fetchImage(url: url) { error, image in
            guard let image = image else { return }
            self.albumArt.image = image
        }
    }
    
    func load(fromNIBNamed nibName: String) -> Bool {
        var nibObjects: NSArray?
        let nibName = NSNib.Name(stringLiteral: nibName)
        
        if Bundle.main.loadNibNamed(nibName, owner: self, topLevelObjects: &nibObjects) {
            guard let nibObjects = nibObjects else { return false }
            
            let viewObjects = nibObjects.filter { $0 is NSView }
            
            if viewObjects.count > 0 {
                guard let view = viewObjects[0] as? NSView else { return false }
                mainView = view
                self.addSubview(mainView!)
                
                mainView?.translatesAutoresizingMaskIntoConstraints = false
                mainView?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                mainView?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
                mainView?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                mainView?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                
                return true
            }
        }
        
        return false
    }
}


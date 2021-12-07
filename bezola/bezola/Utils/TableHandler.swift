//
//  TableHandler.swift
//  bezola
//
//  Created by Ryan Rau on 12/7/21.
//

import Foundation
import Cocoa

class TableHandler: NSObject {
    var data: [Song]
    
    override init(){
        self.data = []
    }
    
    func updateData(_ data: [Song]){
        self.data = data
    }
}

extension TableHandler: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        tableView.reloadData()
    }
}

extension TableHandler: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let sample = data[row]
        
        let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "dataCell")
        guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
        cellView.textField?.stringValue = sample.track + " - " + sample.artist + " (" + sample.year + ")"
        return cellView
            
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
}

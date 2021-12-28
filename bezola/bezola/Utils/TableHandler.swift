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
    
    var onAddToQueue : ((Song) -> Void)? = nil
    
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
        
        let view = SongTableCell()
        view.track.stringValue = sample.track
        view.artist.stringValue = sample.artist
        view.year.stringValue = sample.year
        view.onAddToQueue = {
            if let onAddToQueue = self.onAddToQueue {
                onAddToQueue(self.data[row])
            }
        }
        
        view.loadImage(url: sample.albumURL)
        
        return view
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
}

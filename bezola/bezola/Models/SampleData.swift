//
//  SampleData.swift
//  bezola
//
//  Created by Ryan Rau on 12/7/21.
//

import Foundation
import SwiftUI

struct SampleData: Codable {
    var samples: [Song]
    var sampled_by: [Song]
    
//    init(_ input: String) {
//        let split = input.split(separator: "%").map(String.init)
//
//        self.track = split[0]
//        self.artist = split[1]
//    }
//
    init() {
        self.samples = []
        self.sampled_by = []
    }
}

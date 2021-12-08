//
//  SampleData.swift
//  bezola
//
//  Created by Ryan Rau on 12/7/21.
//

import Foundation
import SwiftUI

struct SampleData: Decodable {
    var samples: [Song]
    var sampled_by: [Song]
    
    init() {
        self.samples = []
        self.sampled_by = []
    }
}

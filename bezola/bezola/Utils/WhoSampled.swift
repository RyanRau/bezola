//
//  WhoSampled.swift
//  bezola
//
//  Created by Ryan Rau on 12/7/21.
//

import Foundation
import PythonKit

class WhoSampled {
    static func getSampleData(_ track: String, _ artist: String) -> SampleData {
        let decoder = JSONDecoder()
        let sys = Python.import("sys")
        
        sys.path.append("/Users/ryanrau/Documents/Code/bezola/who_sampled_scraper/") // TODO: Change to dynamic path
        let scraper = Python.import("scraper")
        
//        scraper.ping() // Sanity check
        
        let result = scraper.get_data(artist, track)
        let result_string = String(result)!
        
        do {
            let data = try decoder.decode(SampleData.self, from: Data(result_string.utf8))
            return data
        }
        catch{
            print(error.localizedDescription)
            return SampleData()
        }
    }
    
}

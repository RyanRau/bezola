//
//  WhoSampled.swift
//  bezola
//
//  Created by Ryan Rau on 12/7/21.
//

import Foundation
import PythonKit

class WhoSampled {
    static func getSampleData(_ track: String, _ artist: String, completion: @escaping (SampleData) -> ()) {
        let decoder = JSONDecoder()
        let sys = Python.import("sys")
        
        DispatchQueue.main.async() {
            sys.path.append("/Users/ryanrau/Documents/Repos/bezola/who_sampled_scraper/") // TODO: Change to dynamic path
            let scraper = Python.import("scraper")
            
    //        scraper.ping() // Sanity check
            
            let result = scraper.get_data(artist, track)
            let result_string = String(result)!
            
            do {
                let data = try decoder.decode(SampleData.self, from: Data(result_string.utf8))
                completion(data)
            }
            catch{
                print(error.localizedDescription)
                completion(SampleData())
            }
        }
    }
    
    
}

//
//  WhoSampled.swift
//  bezola
//
//  Created by Ryan Rau on 12/7/21.
//

import Foundation
import PythonKit

class WhoSampled {
    static func getSampleData(_ track: String, _ artist: String, completion: @escaping (WhoSampledData) -> ()) {
        let decoder = JSONDecoder()
        let file = Array("scraper.py")
        let sys = Python.import("sys")
        
        DispatchQueue.main.async() {
            guard let fullPath = Bundle.main.path(forResource: String(file[..<7]), ofType: String(file[8...])) else {
                print("FAILED TO LOAD PYTHON FILE")
                return
            }
            let directoryPath = String(Array(fullPath)[..<(fullPath.count - file.count)])
            
            sys.path.append(directoryPath)
            
            let scraper = Python.import("scraper")
            
//            scraper.ping() // Sanity check
            
            let result = scraper.get_data(artist, track)
            let result_string = String(result)!
            
            do {
                let data = try decoder.decode(WhoSampledData.self, from: Data(result_string.utf8))
                completion(data)
            }
            catch{
                print(error.localizedDescription)
                completion(WhoSampledData())
            }
        }
    }
}

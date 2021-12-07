//
//  Helpers.swift
//  bezola
//
//  Created by Ryan Rau on 12/7/21.
//

import Foundation

class Helpers {
    
    static func get(url: String, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }.resume()
    }
    
}

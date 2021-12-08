//
//  Helpers.swift
//  bezola
//
//  Created by Ryan Rau on 12/7/21.
//

import Foundation
import Cocoa

class Helpers {
    
    static func fetchImage(url: String, completion: @escaping (Bool, NSImage?) -> ()) {
        Helpers.get(url: url)  { data, response, error in
            DispatchQueue.main.async() {
                guard let data = data, error == nil else {
                    completion(true, nil)
                    return
                }
                completion(false, NSImage(data: data))
            }
        }
    }
    
    static func get(url: String, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }.resume()
    }
    
}

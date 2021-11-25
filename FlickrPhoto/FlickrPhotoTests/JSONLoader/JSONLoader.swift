//
//  JsonLoader.swift
//  FlickrPhotoTests
//
//  Created by Ahmed Elsman on 24/11/2021.
//

import Foundation

final class JSONLoader {

     func loadJsonData(file: String) -> Data? {

        if let jsonFilePath = Bundle(for: type(of: self)).path(forResource: file, ofType: "json") {
            let jsonFileURL = URL(fileURLWithPath: jsonFilePath)

            if let jsonData = try? Data(contentsOf: jsonFileURL) {
                return jsonData
            }
        }
        return nil
    }
}

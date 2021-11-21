//
//  FlickrSearchResult.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import Foundation

struct FlickrSearchResult: Decodable {

    let photos: Photos?

    private enum CodingKeys: String, CodingKey {
        case photos
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        photos = try? values.decodeIfPresent(Photos.self, forKey: .photos)
    }
}

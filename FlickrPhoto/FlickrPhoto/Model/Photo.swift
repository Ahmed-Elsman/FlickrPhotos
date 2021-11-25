//
//  Photo.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import Foundation

struct Photo: Decodable {

    let imagePath: String

    private enum CodingKeys: String, CodingKey {
        case farm
        case id
        case secret
        case server
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let farm = try values.decode(Int.self, forKey: .farm)
        let id = try values.decode(String.self, forKey: .id)
        let secret = try values.decode(String.self, forKey: .secret)
        let server = try values.decode(String.self, forKey: .server)
        imagePath = "http://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret).jpg"
    }
}

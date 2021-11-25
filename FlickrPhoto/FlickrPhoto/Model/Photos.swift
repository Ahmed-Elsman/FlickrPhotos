//
//  Photos.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import Foundation

struct Photos: Decodable {

    let currentPage: Int
    let totalPages: Int
    let photos: [Photo]

    private enum CodingKeys: String, CodingKey {

        case currentPage = "page"
        case totalPages = "pages"
        case photos = "photo"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currentPage = try values.decode(Int.self, forKey: .currentPage)
        totalPages = try values.decode(Int.self, forKey: .totalPages)
        photos = try values.decode([Photo].self, forKey: .photos)
    }
}

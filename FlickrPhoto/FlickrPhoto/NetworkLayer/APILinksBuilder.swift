//
//  APILinksBuilder.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import Foundation

struct APILinksBuilder {
    
    static let apiKey: String = "7ae5dd61ab369ce45e5cba1f5e947059"
    private static let baseURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&format=json&nojsoncallback=1"

    enum API {
        case search(searchKeyword: String, photosPerPage: Int, page: Int)

        var path: String? {
            switch self {
            case .search(let searchKeyword, let photosPerPage, let page):
                if let encodedText = searchKeyword.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
                    return APILinksBuilder.baseURL + "&text=\(encodedText)&per_page=\(photosPerPage)&page=\(page)"
                }
                return nil
            }
        }
    }
}

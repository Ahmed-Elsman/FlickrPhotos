//
//  WebPhotosRepository.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import Foundation
import Combine

final class WebPhotosRepository: PhotosRepository {

    let provider: Requestable

    init(provider: Requestable = APIProvider()) {
        self.provider =  provider
    }

    func photos(for query: String, page: Int)  -> AnyPublisher<FlickrSearchResult, FlickrPhotoError> {
        guard let path = APILinksBuilder.API.search(searchKeyword: query, photosPerPage: Constant.numberOfPhotosPerPage, page: page).path,
              let url = URL(string: path) else {
                  return Fail(error: FlickrPhotoError.wrongURL).eraseToAnyPublisher()
              }
        return provider.loadData(from: url)
    }
}

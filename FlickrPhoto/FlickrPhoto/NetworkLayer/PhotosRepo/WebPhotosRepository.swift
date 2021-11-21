//
//  WebPhotosRepository.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import Foundation
import Combine

protocol PhotosRepository {
    func photos(for query: String, page: Int) throws -> AnyPublisher<FlickrSearchResult, FlickrPhotoError>
}


final class WebPhotosRepository: PhotosRepository {
    
    let loader: APILoader

    init(loader: APILoader = APILoader()) {
        self.loader =  loader
    }
    
    func photos(for query: String, page: Int) throws -> AnyPublisher<FlickrSearchResult, FlickrPhotoError> {
        guard let path = APILinksBuilder.API.search(searchKeyword: query, photosPerPage: Constant.numberOfPhotosPerPage, page: page).path,
              let url = URL(string: path) else {
                  throw FlickrPhotoError.wrongURL
              }
        return loader.loadData(from: url)
    }
}

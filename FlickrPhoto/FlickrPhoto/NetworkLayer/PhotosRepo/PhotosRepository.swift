//
//  PhotosRepository.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import Foundation
import Combine

protocol PhotosRepository {
    func photos(for query: String, page: Int) throws -> AnyPublisher<FlickrSearchResult, FlickrPhotoError>
}

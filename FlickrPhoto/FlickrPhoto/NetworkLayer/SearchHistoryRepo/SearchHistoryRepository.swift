//
//  SearchHistoryRepository.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 22/11/2021.
//

import Foundation
import Combine

protocol SearchHistoryRepository {
    var searchHistorySubject: CurrentValueSubject<[String], FlickrPhotoError> { get set }
    func getSearchHistory()
    func saveSearchKeyword(searchKeyword: String)
    func clearSearchHistory()
}

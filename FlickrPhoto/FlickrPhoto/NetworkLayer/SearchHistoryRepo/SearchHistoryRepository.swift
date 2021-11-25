//
//  SearchHistoryRepository.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 22/11/2021.
//

import Foundation

protocol SearchHistoryRepository {
    func getSearchHistory() -> [String]
    func saveSearchKeyword(searchKeyword: String) -> [String]
    func clearSearchHistory() -> [String]
}

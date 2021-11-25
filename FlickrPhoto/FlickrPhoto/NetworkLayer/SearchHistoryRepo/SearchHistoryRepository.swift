//
//  SearchHistoryRepository.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 22/11/2021.
//

import Foundation

#warning("I Need To convert it to combine.")

protocol SearchHistoryRepository {
    func getSearchHistory() -> [String]
    func saveSearchKeyword(searchKeyword: String) -> [String]
    func clearSearchHistory() -> [String]
}

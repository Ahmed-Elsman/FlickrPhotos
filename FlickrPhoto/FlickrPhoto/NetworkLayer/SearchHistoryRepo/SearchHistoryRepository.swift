//
//  SearchHistoryRepository.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 22/11/2021.
//

import Foundation

final class SearchHistoryRepository {
    
    func getSearchHistory() -> [String] {
        if let history = UserDefaults.standard.array(forKey: UserDefaultsKey.searchHistoryOfPhotos.rawValue) as? [String] {
            return history
        }
        return []
        
    }
    
    @discardableResult
    func saveSearchKeyword(searchKeyword: String) -> [String] {
        let history = getSearchHistory()
        guard !searchKeyword.isEmpty else {
            return history
        }
        
        let lowercaseKeyword = searchKeyword.lowercased()
        var result = history.filter { keyword -> Bool in
            keyword.lowercased() != lowercaseKeyword
        }
        result.append(searchKeyword)
        UserDefaults.standard.set(result, forKey: UserDefaultsKey.searchHistoryOfPhotos.rawValue)
        return history
    }
    
    func clearSearchHistory() -> [String] {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.searchHistoryOfPhotos.rawValue)
        return []
    }
}

enum UserDefaultsKey: String {
    case searchHistoryOfPhotos
}

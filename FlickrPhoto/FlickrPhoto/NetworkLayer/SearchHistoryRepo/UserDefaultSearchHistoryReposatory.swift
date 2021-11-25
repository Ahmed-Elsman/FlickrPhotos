//
//  UserDefaultSearchHistoryReposatory.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 25/11/2021.
//

import Foundation
import Combine

final class UserDefaultSearchHistoryRepository: SearchHistoryRepository {
    var searchHistorySubject: CurrentValueSubject<[String], FlickrPhotoError> = CurrentValueSubject<[String], FlickrPhotoError>([])

    init() {
        getSearchHistory()
    }

    func getSearchHistory() {
        if let history = UserDefaults.standard.array(forKey: UserDefaultsKey.photosSearchHistory.rawValue) as? [String] {
            searchHistorySubject.send(history)
        } else {
            searchHistorySubject.send([])
        }
    }

    func saveSearchKeyword(searchKeyword: String) {
        let history = searchHistorySubject.value

        let lowercaseKeyword = searchKeyword.lowercased()
        var result = history.filter { keyword -> Bool in
            keyword.lowercased() != lowercaseKeyword
        }
        result.append(searchKeyword)
        UserDefaults.standard.set(result, forKey: UserDefaultsKey.photosSearchHistory.rawValue)
        searchHistorySubject.send(result)
    }

    func clearSearchHistory() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.photosSearchHistory.rawValue)
        searchHistorySubject.send([])
    }
}

enum UserDefaultsKey: String {
    case photosSearchHistory
}

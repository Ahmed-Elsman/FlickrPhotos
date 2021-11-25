//
//  PhotosListViewModel+State.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 25/11/2021.
//

import Foundation

extension PhotosListViewModel {
    
    enum State: Equatable {
        
        case searchResult(term: String, page: Int)
        case searchHistory
        
        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.searchHistory, .searchHistory):
                return true
            case (let .searchResult(term1, page1), let .searchResult(term2, page2)):
                return term1 == term2 && page1 == page2
                
            default:
                return false
            }
        }
        
        static func isDublicated(lhsState: State, rhsState: State) -> Bool {
            switch (lhsState, rhsState) {
            case (.searchHistory, .searchHistory), ( .searchResult, .searchResult):
                return true
            default:
                return false
            }
        }
    }
}

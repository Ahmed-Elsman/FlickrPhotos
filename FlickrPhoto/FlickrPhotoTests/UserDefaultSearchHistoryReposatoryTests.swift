//
//  File.swift
//  FlickrPhotoTests
//
//  Created by Ahmed Elsman on 25/11/2021.
//

import XCTest
import Combine
@testable import FlickrPhoto

class UserDefaultSearchHistoryReposatoryTests: XCTestCase {
    
    var userDefaultSearchHistoryRepository: UserDefaultSearchHistoryRepository!
    var subscriptions = Set<AnyCancellable>()
    
    override func setUp() {
        userDefaultSearchHistoryRepository = UserDefaultSearchHistoryRepository()
        subscriptions = []
    }
    
    func test_ClearHistorySuccess() {
        let promise = XCTestExpectation(description: "Clearing Search History Success")
        userDefaultSearchHistoryRepository.clearSearchHistory()
        userDefaultSearchHistoryRepository.searchHistorySubject.sink(receiveCompletion: {  _ in
            XCTFail("Clearing Fail")
        }, receiveValue: { photos in
            XCTAssertEqual(photos.count, 0)
            promise.fulfill()
        }).store(in: &subscriptions)
        
        wait(for: [promise], timeout: 1)
    }
    
    func test_SaveDataSuccess() {
        let promise = XCTestExpectation(description: "Saving Success")
        userDefaultSearchHistoryRepository.saveSearchKeyword(searchKeyword: "Tree")
        userDefaultSearchHistoryRepository.searchHistorySubject.sink(receiveCompletion: {  _ in
            XCTFail("Saving Fail")
        }, receiveValue: { photos in
            XCTAssertGreaterThan(photos.count, 0)
            promise.fulfill()
        }).store(in: &subscriptions)
        
        wait(for: [promise], timeout: 1)
    }
    
    func test_GetDataSuccess() {
        let promise = XCTestExpectation(description: "Getting Data Success")
        userDefaultSearchHistoryRepository.saveSearchKeyword(searchKeyword: "Tree")
        userDefaultSearchHistoryRepository.searchHistorySubject.sink(receiveCompletion: {  _ in
            XCTFail("Getting Data Fail")
        }, receiveValue: { photos in
            XCTAssertGreaterThan(photos.count, 0)
            promise.fulfill()
        }).store(in: &subscriptions)
        
        wait(for: [promise], timeout: 1)
    }
}

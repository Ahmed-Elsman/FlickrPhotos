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

    override func setUp() {
        userDefaultSearchHistoryRepository = UserDefaultSearchHistoryRepository()
    }

    func test_ClearHistorySuccess() {
        let promise = XCTestExpectation(description: "Clearing Search History Success")
        let keywords = userDefaultSearchHistoryRepository.clearSearchHistory()
        XCTAssertEqual(keywords.count, 0)
        promise.fulfill()
    }

    func test_SaveDataSuccess() {
        let promise = XCTestExpectation(description: "Saving Success")
        userDefaultSearchHistoryRepository.saveSearchKeyword(searchKeyword: "Tree")
        let keywords = userDefaultSearchHistoryRepository.getSearchHistory()
        XCTAssertEqual(keywords.count, 1)
        promise.fulfill()
    }

    func test_GetDataSuccess() {
        let promise = XCTestExpectation(description: "Getting Data Success")
        let keywords = userDefaultSearchHistoryRepository.getSearchHistory()
        XCTAssertEqual(keywords.count, 1)
        promise.fulfill()
    }
}

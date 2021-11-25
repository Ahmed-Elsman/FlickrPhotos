//
//  PhotosListViewModelTests.swift
//  FlickrPhotoTests
//
//  Created by Ahmed Elsman on 25/11/2021.
//

import XCTest
import Combine
@testable import FlickrPhoto

class PhotosListViewModelTests: XCTestCase {
    
    var webPhotosRepository: WebPhotosRepository!
    var photosListViewModel: PhotosListViewModel!
    var subscriptions: Set<AnyCancellable>!
    
    override func setUp() {
        subscriptions = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        webPhotosRepository =  nil
        photosListViewModel = nil
        subscriptions = nil
        super.tearDown()
    }
    
    func test_SearchFileFail() {
        webPhotosRepository = WebPhotosRepository(provider: MockAPIProvider.createMockAPIProvider(fromJsonFile: "noData", statusCode: 200, error: nil))
        photosListViewModel = PhotosListViewModel(output: PhotosListViewController(), photosRepository: webPhotosRepository)
        let promise = XCTestExpectation(description: "No Photos From File Fetched")
        photosListViewModel.state.send(.searchResult(term: "", page: 1))
        photosListViewModel.itemsForCollection.sink(receiveCompletion: {  _ in
            XCTFail("Fetching Fail")
        }, receiveValue: { response in
            XCTAssertEqual(response.count, 0)
            promise.fulfill()
        }).store(in: &subscriptions)
        
        wait(for: [promise], timeout: 3)
    }
    
    func test_SearchFileSuccess() {
        webPhotosRepository = WebPhotosRepository(provider: MockAPIProvider.createMockAPIProvider(fromJsonFile: "photosData", statusCode: 200, error: nil))
        photosListViewModel = PhotosListViewModel(output: PhotosListViewController(), photosRepository: webPhotosRepository)
        let promise = XCTestExpectation(description: "Fetching Photos From File Success")
        photosListViewModel.state.send(.searchResult(term: "", page: 1))
        photosListViewModel.itemsForCollection.dropFirst().sink(receiveCompletion: {  _ in
            XCTFail("Fetching Fail")
        }, receiveValue: { response in
            XCTAssertGreaterThan(response.count, 0)
            promise.fulfill()
        }).store(in: &subscriptions)
        
        wait(for: [promise], timeout: 3)
    }
    
    func test_SearchAPISuccess() {
        photosListViewModel = PhotosListViewModel(output: PhotosListViewController())
        let promise = XCTestExpectation(description: "Fetching Photos From API Success")
        photosListViewModel.state.send(.searchResult(term: "photo", page: 1))
        photosListViewModel.itemsForCollection.dropFirst().sink(receiveCompletion: {  _ in
            XCTFail("Fetching Fail")
        }, receiveValue: { response in
            XCTAssertGreaterThan(response.count, 0)
            promise.fulfill()
        }).store(in: &subscriptions)
        
        wait(for: [promise], timeout: 15)
    }
    
    func test_LoadMoreAPISuccess() {
        photosListViewModel = PhotosListViewModel(output: PhotosListViewController())
        let promise = XCTestExpectation(description: "Fetching More Photos From API Success")
        photosListViewModel.state.send(.searchResult(term: "Tree", page: 1))
        photosListViewModel.loadMoreData(2)
        photosListViewModel.itemsForCollection.dropFirst().sink(receiveCompletion: {  _ in
            XCTFail("Fetching Fail")
        }, receiveValue: { response in
            XCTAssertGreaterThan(response.count, 0)
            promise.fulfill()
        }).store(in: &subscriptions)
        
        wait(for: [promise], timeout: 15)
    }
}

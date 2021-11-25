//
//  FlickrPhotoTests.swift
//  FlickrPhotoTests
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import XCTest
import Combine
@testable import FlickrPhoto

class WebPhotosRepositoryTests: XCTestCase {
    
    var webPhotosRepository: WebPhotosRepository!
    var subscriptions = Set<AnyCancellable>()
    
    override func setUp() {
        subscriptions = []
    }
    
    func test_FetchingPhotosFromFile_Success() throws {
        
        webPhotosRepository = WebPhotosRepository(provider: MockAPIProvider.createMockAPIProvider(fromJsonFile: "photosData", statusCode: 200, error: nil))
        
        let promise = XCTestExpectation(description: "Fetching Photos From File Success")
        webPhotosRepository.photos(for: "", page: 1).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                XCTFail("Fetching Fail \(error.localizedDescription)")
            }
        }, receiveValue: { response in
            guard let photos = response.photos?.photos else {
                XCTFail("Fetching Photos failed")
                return
            }
            XCTAssertGreaterThan(photos.count, 0)
            promise.fulfill()
        }).store(in: &subscriptions)
        
        wait(for: [promise], timeout: 1)
    }
    
    func test_FetchingPhotosFromFile_Fail() throws {
        
        webPhotosRepository = WebPhotosRepository(provider: MockAPIProvider.createMockAPIProvider(fromJsonFile: "noData", statusCode: 200, error: nil))
        
        let promise = XCTestExpectation(description: "No Photos From File Fetched")
        webPhotosRepository.photos(for: "", page: 1).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                XCTFail("Fetching Fail \(error.localizedDescription)")
            }
        }, receiveValue: { response in
            guard let photos = response.photos?.photos else {
                XCTFail("Fetching Photos failed")
                return
            }
            XCTAssertEqual(photos.count, 0)
            promise.fulfill()
        }).store(in: &subscriptions)
        
        wait(for: [promise], timeout: 1)
    }
    
    func test_FetchingPhotosFromApi_Success() throws {
        
        webPhotosRepository = WebPhotosRepository(provider: APIProvider())
        
        let promise = XCTestExpectation(description: "Fetching Photos From API Success")
        webPhotosRepository.photos(for: "photo", page: 1).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                XCTFail("Fetching Fail \(error.localizedDescription)")
            }
        }, receiveValue: { response in
            guard let photos = response.photos?.photos else {
                XCTFail("Fetching Photos failed")
                return
            }
            XCTAssertGreaterThan(photos.count, 0)
            promise.fulfill()
        }).store(in: &subscriptions)
        
        wait(for: [promise], timeout: 15)
    }
    
    func test_FetchingPhotosFromApi_Fail() throws {
        webPhotosRepository = WebPhotosRepository(provider: APIProvider())
        let promise = XCTestExpectation(description: "No Photos From API Fetched")
        webPhotosRepository.photos(for: "شسيبللا", page: 1).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                XCTFail("Fetching Fail \(error.localizedDescription)")
            }
        }, receiveValue: { response in
            guard let photos = response.photos?.photos else {
                XCTFail("Fetching Photos failed")
                return
            }
            XCTAssertEqual(photos.count, 0)
            promise.fulfill()
        }).store(in: &subscriptions)
        
        wait(for: [promise], timeout: 15)
    }
    
    func test_FetchingPhotosFromApiPaging() throws {
        webPhotosRepository = WebPhotosRepository(provider: APIProvider())
        let promise = XCTestExpectation(description: "Fetching First Photos Page")
        webPhotosRepository.photos(for: "photo", page: 1).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                XCTFail("Fetching Fail \(error.localizedDescription)")
            }
        }, receiveValue: { response in
            let photos = response.photos?.photos
            XCTAssertEqual(photos?.count, Constant.numberOfPhotosPerPage, "photos are equal to \(Constant.numberOfPhotosPerPage)")
            promise.fulfill()
        }).store(in: &subscriptions)
        
        wait(for: [promise], timeout: 15)
    }
    
    func test_LoadingMorePhotosFromApiPaging() throws {
        webPhotosRepository = WebPhotosRepository(provider: APIProvider())
        let promise = XCTestExpectation(description: "Fetching Second Photos Page")
        webPhotosRepository.photos(for: "photo", page: 2).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                XCTFail("Fetching Fail \(error.localizedDescription)")
            }
        }, receiveValue: { response in
            XCTAssertEqual(response.photos?.photos.count, Constant.numberOfPhotosPerPage, "photos are equal to \(Constant.numberOfPhotosPerPage)")
            promise.fulfill()
        }).store(in: &subscriptions)
        
        wait(for: [promise], timeout: 15)
    }
    
}

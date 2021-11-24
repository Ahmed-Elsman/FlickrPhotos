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
        webPhotosRepository = WebPhotosRepository(loader: APILoader())
    }
    
    func test_fetching_photos_success() {
        
        let promise = XCTestExpectation(description: "Fetching Photos Success")
        try? webPhotosRepository.photos(for: "photo", page: 1)
            .sink(receiveCompletion: { _ in }) { response in
                guard let photos = response.photos?.photos else {
                    XCTFail("Fetching Photos failed")
                    return
                }
                XCTAssertGreaterThan(photos.count, 0)
                promise.fulfill()
            }.store(in: &subscriptions)
        
        wait(for: [promise], timeout: 15)
    }
    
    func test_fetching_photos_fail() {
        
        let promise = XCTestExpectation(description: "Fetching Photos Fail")
        try? webPhotosRepository.photos(for: "شسيبللا", page: 1)
            .sink(receiveCompletion: { _ in }) { response in
                guard let photos = response.photos?.photos else {
                    XCTFail("Fetching Photos failed")
                    return
                }
                XCTAssertEqual(photos.count, 0)
                promise.fulfill()
            }.store(in: &subscriptions)
        
        wait(for: [promise], timeout: 15)
    }
    
    func test_fetch_first_photos() {
        
        let promise = XCTestExpectation(description: "Fetching First Photos Page")
        try? webPhotosRepository.photos(for: "photo", page: 1)
            .sink(receiveCompletion: { _ in }) { response in
                let photos = response.photos?.photos
                XCTAssertEqual(photos?.count, Constant.numberOfPhotosPerPage, "photos are equal to \(Constant.numberOfPhotosPerPage)")
                promise.fulfill()
            }.store(in: &subscriptions)
        
        wait(for: [promise], timeout: 15)
    }
    
    
    func test_fetch_loadingMore_photos() {
        
        let promise = XCTestExpectation(description: "Fetching Second Photos Page")
        try? webPhotosRepository.photos(for: "photo", page: 2)
            .sink(receiveCompletion: { _ in }) { response in
                XCTAssertEqual(response.photos?.photos.count, Constant.numberOfPhotosPerPage, "photos are equal to \(Constant.numberOfPhotosPerPage)")
                promise.fulfill()
            }.store(in: &subscriptions)
        
        wait(for: [promise], timeout: 15)
    }
    
    
}



//
//  APILoaderMock.swift
//  FlickrPhotoTests
//
//  Created by Ahmed Elsman on 24/11/2021.
//

import Foundation
import Combine
@testable import FlickrPhoto

struct MockAPIProvider: Requestable {

    var data: Data?
    var response: URLResponse?
    var error: Error?

    func loadData<T: Decodable>(from url: URL) -> AnyPublisher<T, FlickrPhotoError> {
        data.publisher.tryMap { _ in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                      throw URLError(.badServerResponse)
                  }
            guard let data = data else { throw FlickrPhotoError.noResults }
            return data
        }
        .decode(type: T.self, decoder: JSONDecoder())
        .mapError({ error -> FlickrPhotoError in
            error as? FlickrPhotoError ?? FlickrPhotoError.runtimeError("Wrong !!")
        })
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()

    }

    static func createMockAPIProvider(fromJsonFile file: String,
                                      statusCode: Int,
                                      error: Error?) -> MockAPIProvider {

        let data = JSONLoader().loadJsonData(file: file)

        let response = HTTPURLResponse(url: URL(string: "URL")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)

        return MockAPIProvider(data: data, response: response, error: error)
    }
}

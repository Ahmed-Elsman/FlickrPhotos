//
//  APILoader.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import Foundation
import Combine

protocol Requestable {
    func loadData<T: Decodable>(from url: URL) -> AnyPublisher<T, FlickrPhotoError>
}

final class APIProvider: Requestable {

    func loadData<T: Decodable>(from url: URL) -> AnyPublisher<T, FlickrPhotoError> {
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                          throw URLError(.badServerResponse)
                      }
                return element.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError({ error -> FlickrPhotoError in
                error as? FlickrPhotoError ?? FlickrPhotoError.runtimeError("Wrong !!")
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

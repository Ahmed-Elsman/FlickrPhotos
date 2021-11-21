//
//  FlickerPhotoError.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import Foundation

enum FlickrPhotoError: Error {
    case failedConnection
    case wrongURL
    case noResults
    case noInternetConnection
    case runtimeError(String)
    case parseError
    case fileNotFound

    var localizedDescription: String {
        switch self {
        case .noResults:
            return "No Photos Found"
        case .noInternetConnection:
            return "There is No Internet Connection"
        default:
            return "Error Found"
        }
    }
}

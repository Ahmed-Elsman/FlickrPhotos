//
//  CellReusable.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 22/11/2021.
//

import Foundation

protocol CellReusable {
    static var identifier: String { get }
}

extension CellReusable {
    static var identifier: String {
        return "\(self)"
    }
}

//
//  ReusableCellForCollectionView.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import UIKit

extension UICollectionView {

    func registerCell<Cell: UICollectionViewCell>(type: Cell.Type, identifier: String? = nil) {
        let identifier = identifier ?? String(describing: type)
        register(type, forCellWithReuseIdentifier: identifier)
    }

    func dequeueCell<Cell: UICollectionViewCell>(type: Cell.Type, identifier: String? = nil, indexPath: IndexPath) -> Cell? {
        let identifier = identifier ?? String(describing: type)
        return dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell
    }
}

#warning("add this in another file")

protocol CellReusable {
    static var identifier: String { get }
}

extension CellReusable {
    static var identifier: String {
        return "\(self)"
    }
}

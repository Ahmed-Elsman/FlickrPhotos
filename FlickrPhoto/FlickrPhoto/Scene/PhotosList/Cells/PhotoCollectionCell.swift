//
//  PhotoCollectionCell.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import UIKit

class PhotoCollectionCell: UICollectionViewCell {
    
}




#warning("Move it in another file")

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

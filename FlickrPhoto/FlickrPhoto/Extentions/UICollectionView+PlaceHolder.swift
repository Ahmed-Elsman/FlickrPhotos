//
//  UICollectionView+PlaceHolder.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 25/11/2021.
//

import Foundation
import UIKit

extension UICollectionView {

    func setEmptyView(emptyPlaceHolderType: EmptyPlaceHolderType, completionBlock: (() -> Void)? = nil) {
        let frame = CGRect(x: center.x, y: center.y, width: bounds.size.width, height: bounds.size.height)
        let emptyPlaceHolderView = EmptyPlaceHolderView(frame: frame)
        emptyPlaceHolderView.translatesAutoresizingMaskIntoConstraints = false
        emptyPlaceHolderView.emptyPlaceHolderType = emptyPlaceHolderType
        backgroundView = emptyPlaceHolderView
        NSLayoutConstraint.activate([
            emptyPlaceHolderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyPlaceHolderView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyPlaceHolderView.widthAnchor.constraint(equalTo: widthAnchor),
            emptyPlaceHolderView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    func restore() {
        backgroundView = nil
    }
}

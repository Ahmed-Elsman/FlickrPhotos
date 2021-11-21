//
//  PhotosCollectionDataSource.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import UIKit

final class PhotosCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var itemsForCollection: [ItemCollectionViewCellType] = []
    
    weak var viewModelInput: PhotosListViewModel?
    
    private struct CellHeightConstant {
        static let heightOfPhotoCell: CGFloat = 120
    }
    
    init(viewModelInput: PhotosListViewModel?, itemsForCollection: [ItemCollectionViewCellType]) {
        self.itemsForCollection = itemsForCollection
        self.viewModelInput = viewModelInput
    }
    
    // MARK: - Collection view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsForCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = itemsForCollection[indexPath.row]
        switch item {
        case .photo(let photo):
            if let cell = collectionView.dequeueCell(type: PhotoCollectionCell.self, indexPath: indexPath) {
                cell.configCell(photo: photo)
                return cell
            }
        }

        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let item = itemsForCollection[indexPath.row]
        switch item {
        case .photo:
            return getPhotoCellSize(collectionView: collectionView)
        }
    }
    
    private func getPhotoCellSize(collectionView: UICollectionView) -> CGSize {
        let widthAndHeight = (collectionView.bounds.width / 2) - 10
        return CGSize(width: widthAndHeight, height: widthAndHeight)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }
}


#warning("add this in another file")
enum ItemCollectionViewCellType {
    case photo(photo: Photo)
}

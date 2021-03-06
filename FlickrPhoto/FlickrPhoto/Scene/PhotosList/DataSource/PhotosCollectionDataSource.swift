//
//  PhotosCollectionDataSource.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import UIKit

final class PhotosCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var itemsForCollection: [ItemCollectionViewCellType] = []

    weak var viewModelInput: PhotosListViewModelInput?

    private struct CellHeightConstant {
        static let heightOfPhotoCell: CGFloat = 120
        static let heightOfSearchTermCell: CGFloat = 50
        static let heightOfHistoryHeader: CGFloat = 120
    }

    init(viewModelInput: PhotosListViewModelInput?, itemsForCollection: [ItemCollectionViewCellType]) {
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
        case .search(let term):
            if let cell = collectionView.dequeueCell(type: SearchHistoryCollectionCell.self, indexPath: indexPath) {
                cell.configCell(searchTerm: term)
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
        case .search:
            return CGSize(width: collectionView.bounds.width, height: CellHeightConstant.heightOfSearchTermCell)
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {

        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionCell.identifier, for: indexPath)  as! HeaderCollectionCell
            if let state =  viewModelInput?.state {
                switch state.value {
                case .searchHistory:
                    headerView.configCell(searchTerm: "Search History")
                case .searchResult(let term, _):
                    let headerTitle = "Searching For \(term)"
                    headerView.configCell(searchTerm: headerTitle)
                }
            }
            return headerView
        default:

            assert(false, "Unexpected element kind")
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if case let .search(term) = itemsForCollection[indexPath.row] {
            viewModelInput?.state.send(.searchResult(term: term, page: 1))
        }
    }

    private func getPhotoCellSize(collectionView: UICollectionView) -> CGSize {
        let widthAndHeight = (collectionView.bounds.width / 2) - 10
        return CGSize(width: widthAndHeight, height: widthAndHeight)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if case .photo = itemsForCollection[indexPath.row], indexPath.row == itemsForCollection.count - 1 {
            let pageToGet = Int((Float(indexPath.row) / Float(Constant.numberOfPhotosPerPage)).rounded(.up)) + 1
            viewModelInput?.loadMoreData(pageToGet)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }
}

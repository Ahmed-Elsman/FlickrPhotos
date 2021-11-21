//
//  PhotosListViewModel.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import Foundation
import Combine

protocol PhotosListViewModelInput: AnyObject {
    func search(for text: String)
    var itemsForCollection: CurrentValueSubject<[ItemCollectionViewCellType], Never> { get set }
}


final class PhotosListViewModel {
    
    fileprivate var page: Int = 1
    fileprivate var canLoadMore = true
    
    var itemsForCollection = CurrentValueSubject<[ItemCollectionViewCellType], Never>([])
    var cancelableSet: Set<AnyCancellable> =  Set<AnyCancellable>()
    
    init() {
        
    }
}


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


enum State {
    case searchResult(term: String)
}

final class PhotosListViewModel {
    
    private weak var output: BaseViewModelOutput?
    
    fileprivate var page: Int = 1
    fileprivate var canLoadMore = true
    
    var itemsForCollection = CurrentValueSubject<[ItemCollectionViewCellType], Never>([])
    var state: CurrentValueSubject<State, Never> = CurrentValueSubject<State, Never>(.searchResult(term: ""))
    var cancelableSet: Set<AnyCancellable> =  Set<AnyCancellable>()
    
    init(output: BaseViewModelOutput) {
        self.output = output
    }
}


// MARK: - PhotosListViewModelInput
extension PhotosListViewModel: PhotosListViewModelInput {
    
    func search(for text: String) {
        state.send(.searchResult(term: text))
        itemsForCollection.value = []
        self.page = 1
        self.canLoadMore = true
        getData(for: text)
    }
    
}

// MARK: Setup

extension PhotosListViewModel {
    
    private func getData(for query: String) {
        output?.showLoading()
        canLoadMore = false

    }
}

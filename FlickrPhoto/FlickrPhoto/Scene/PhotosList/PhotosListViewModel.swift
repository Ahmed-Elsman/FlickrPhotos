//
//  PhotosListViewModel.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import Foundation
import Combine

protocol PhotosListViewModelInput: AnyObject {
    var state: CurrentValueSubject<State, Never> { get set }
    var itemsForCollection: CurrentValueSubject<[ItemCollectionViewCellType], FlickrPhotoError> { get set }
    var emptyPlaceHolder: CurrentValueSubject<EmptyPlaceHolderType, Never> { get set }
    
    func search(for text: String)
    func loadMoreData(_ page: Int)
    func getSearchHistory()
}


enum State {
    case searchResult(term: String)
    case searchHistory
}

final class PhotosListViewModel {
    
    private weak var output: BaseViewModelOutput?
    let photosRepository: PhotosRepository
    
    fileprivate var page: Int = 1
    fileprivate var canLoadMore = true
    
    var itemsForCollection = CurrentValueSubject<[ItemCollectionViewCellType], FlickrPhotoError>([])
    var state: CurrentValueSubject<State, Never> = CurrentValueSubject<State, Never>(.searchHistory)
    var cancelableSet: Set<AnyCancellable> =  Set<AnyCancellable>()
    var emptyPlaceHolder = CurrentValueSubject<EmptyPlaceHolderType, Never>(.startSearch)
    
    init(output: BaseViewModelOutput, photosRepository: PhotosRepository = WebPhotosRepository()) {
        self.output = output
        self.photosRepository = photosRepository
        [Notifications.Reachability.connected.name, Notifications.Reachability.notConnected.name].forEach { (notification) in
            NotificationCenter.default.addObserver(self, selector: #selector(changeInternetStatus), name: notification, object: nil)
        }
    }
}


// MARK: - PhotosListViewModelInput
extension PhotosListViewModel: PhotosListViewModelInput {
    
    func search(for keyword: String) {
        state.send(.searchResult(term: keyword))
        itemsForCollection.value = []
        self.page = 1
        self.canLoadMore = true
        let userDetaultSearchHistoryRepository = UserDetaultSearchHistoryRepository()
        userDetaultSearchHistoryRepository.saveSearchKeyword(searchKeyword: keyword)
        getData(for: keyword)
    }
    
    func loadMoreData(_ page: Int) {
        if self.page <= page && canLoadMore == true {
            self.page = page
            if case .searchResult(let query) = state.value {
                getData(for: query)
            }
        }
    }
    
    func getSearchHistory() {
        state.send(.searchHistory)
        let userDetaultSearchHistoryRepository = UserDetaultSearchHistoryRepository()
        let searchTerms = userDetaultSearchHistoryRepository.getSearchHistory()
        itemsForCollection.send(createItemsForCollection(searchTerms: searchTerms))
    }
    
    @objc
    private func changeInternetStatus(notification: Notification) {
        if notification.name == Notifications.Reachability.notConnected.name {
            output?.showError(title: "No Internet Conncection", subtitle: "No Internet Conncection")
            emptyPlaceHolder.send(.noInternetConnection)
        } else {
            emptyPlaceHolder.send(.startSearch)
        }
    }
}

// MARK: Setup

extension PhotosListViewModel {
    
    private func getData(for query: String) {
        guard Reachability.shared.isConnected else {
            emptyPlaceHolder.send(.noInternetConnection)
            return
        }
        output?.showLoading()
        canLoadMore = false
        
        try? photosRepository.photos(for: query, page: page).sink(receiveCompletion: { [unowned self] completion in
            self.output?.hideLoading()
            
            switch completion {
            case .finished:
                break
            case .failure(let error):
                self.itemsForCollection.send(completion: .failure(error))
                
            }
            
        }, receiveValue: { [unowned self] searchResult in
            self.output?.hideLoading()
            
            guard let photos = searchResult.photos, photos.currentPage < photos.totalPages  else {
                self.handleNoPhotos()
                return
            }
            self.handleNewPhotos(photos: photos)
            self.canLoadMore = true
            
        }).store(in: &cancelableSet)
        
    }
    
    private func handleNewPhotos(photos: Photos) {
        let newItems: [ItemCollectionViewCellType] = createItemsForCollection(photosArray: photos.photos)
        itemsForCollection.value.append(contentsOf: newItems)
        if itemsForCollection.value.isEmpty {
            emptyPlaceHolder.send(.noResults)
        } else {
            itemsForCollection.send(newItems)
        }
    }
    
    private func handleNoPhotos() {
        if  itemsForCollection.value.isEmpty {
            emptyPlaceHolder.send(.noResults)
        }
    }
    
    private func createItemsForCollection(photosArray: [Photo]) -> [ItemCollectionViewCellType] {
        return photosArray.map { photo -> ItemCollectionViewCellType  in
                .photo(photo: photo)
        }
    }
    
    private func createItemsForCollection(searchTerms: [String]) -> [ItemCollectionViewCellType] {
        return searchTerms.map { searchTerm -> ItemCollectionViewCellType  in
                .search(term: searchTerm)
        }
    }
}

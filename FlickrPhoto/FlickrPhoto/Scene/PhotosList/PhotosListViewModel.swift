//
//  PhotosListViewModel.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import Foundation
import Combine

protocol PhotosListViewModelInput: AnyObject {
    var state: CurrentValueSubject<PhotosListViewModel.State, Never> { get set }
    var itemsForCollection: CurrentValueSubject<[ItemCollectionViewCellType], FlickrPhotoError> { get set }
    var emptyPlaceHolder: CurrentValueSubject<EmptyPlaceHolderType, Never> { get set }
    func loadMoreData(_ page: Int)
}

final class PhotosListViewModel {
    
    private weak var output: BaseViewModelOutput?
    private let photosRepository: PhotosRepository
    private let searchHistoryRepository: SearchHistoryRepository
    
    fileprivate var canLoadMore = true
    
    var itemsForCollection = CurrentValueSubject<[ItemCollectionViewCellType], FlickrPhotoError>([])
    var state: CurrentValueSubject<State, Never> = CurrentValueSubject<State, Never>(.searchHistory)
    var cancelableSet: Set<AnyCancellable> =  Set<AnyCancellable>()
    var emptyPlaceHolder = CurrentValueSubject<EmptyPlaceHolderType, Never>(.startSearch)
    
    init(output: BaseViewModelOutput,
         photosRepository: PhotosRepository = WebPhotosRepository(),
         searchHistoryRepository: SearchHistoryRepository = UserDefaultSearchHistoryRepository()) {
        self.output = output
        self.photosRepository = photosRepository
        self.searchHistoryRepository = searchHistoryRepository
        [Notifications.Reachability.connected.name, Notifications.Reachability.notConnected.name].forEach { (notification) in
            NotificationCenter.default.addObserver(self, selector: #selector(changeInternetStatus), name: notification, object: nil)
        }
        setupBinding()
    }
    
    private func setupBinding() {
        state
            .removeDuplicates()
            .sink(receiveValue: { state in
                switch state {
                case .searchResult(let term, let page):
                    self.searchHistoryRepository.saveSearchKeyword(searchKeyword: term)
                    self.bind(publisher: self.getData(for: term, page: page))
                case .searchHistory:
                    self.bind(publisher: self.getSearchHistory())
                }
            }).store(in: &cancelableSet)
       
    }
    
    private func bind(publisher: AnyPublisher<[ItemCollectionViewCellType], FlickrPhotoError>) {
        var cancelable: AnyCancellable?
        cancelable = publisher.compactMap { $0 }
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { [unowned self] completion in
            if case let .failure(error) = completion {
                self.emptyPlaceHolder.send(EmptyPlaceHolderType.error(message: error.localizedDescription))
            }
        }, receiveValue: { [unowned self] items in
            self.itemsForCollection.send(items)
            cancelable?.cancel()
        })
        
    }
}

// MARK: - PhotosListViewModelInput
extension PhotosListViewModel: PhotosListViewModelInput {
    
    func loadMoreData(_ page: Int) {
        if case .searchResult(let query, let pageValue) = state.value, pageValue <= page && canLoadMore == true {
            state.send(.searchResult(term: query, page: page))
        }
    }

}

extension PhotosListViewModel {
    
    private func getSearchHistory() -> AnyPublisher<[ItemCollectionViewCellType], FlickrPhotoError> {
        searchHistoryRepository.getSearchHistory()
        return searchHistoryRepository.searchHistorySubject.map { [unowned self] searchTerms -> [ItemCollectionViewCellType] in
            self.createItemsForCollection(searchTerms: searchTerms)
        }.eraseToAnyPublisher()
    }
    
    private func getData(for query: String, page: Int) -> AnyPublisher<[ItemCollectionViewCellType], FlickrPhotoError> {
        guard Reachability.shared.isConnected else {
            emptyPlaceHolder.send(.noInternetConnection)
            return Fail(error: FlickrPhotoError.noInternetConnection).eraseToAnyPublisher()
        }
        output?.showLoading()
        canLoadMore = false
        
        return photosRepository.photos(for: query, page: page).compactMap {$0}.map { [unowned self] searchResult ->  [ItemCollectionViewCellType] in
            return self.handle(searchResult: searchResult)
        }.eraseToAnyPublisher()
    }
    
    // MARK: Helper functions
    
    private func handle(searchResult: FlickrSearchResult) -> [ItemCollectionViewCellType] {
        output?.hideLoading()
        
        guard let photos = searchResult.photos, photos.currentPage < photos.totalPages  else {
            handleNoPhotos()
            return []
        }
        canLoadMore = true
        return createItemsForCollection(photosArray: photos.photos)
    }
    
    private func handleNoPhotos() {
        if  itemsForCollection.value.isEmpty {
            emptyPlaceHolder.send(.noResults)
        }
    }
    
    private func createItemsForCollection(photosArray: [Photo]) -> [ItemCollectionViewCellType] {
        return photosArray.map { photo -> ItemCollectionViewCellType  in
            ItemCollectionViewCellType.photo(photo: photo)
        }
    }
    
    private func createItemsForCollection(searchTerms: [String]) -> [ItemCollectionViewCellType] {
        return searchTerms.map { searchTerm -> ItemCollectionViewCellType in
            ItemCollectionViewCellType.search(term: searchTerm)
        }
    }
    
    // MARK: Handle Internet connection
    @objc
    private func changeInternetStatus(notification: Notification) {
        if notification.name == Notifications.Reachability.notConnected.name {
            output?.showError(title: "No Internet Connection", subtitle: "No Internet Conncection")
            emptyPlaceHolder.send(EmptyPlaceHolderType.noInternetConnection)
        } else {
            emptyPlaceHolder.send(EmptyPlaceHolderType.startSearch)
        }
    }
}

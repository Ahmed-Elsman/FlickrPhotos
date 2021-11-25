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
    func loadMoreData(_ page: Int)
}


enum State: Equatable {

    case searchResult(term: String, page: Int)
    case searchHistory

    static func ==(lhs: State, rhs: State) -> Bool {
        switch (lhs, rhs) {
        case (.searchResult, .searchResult), (.searchHistory, .searchHistory):
            return true
        default:
            return false
        }
    }
}

final class PhotosListViewModel {

    private weak var output: BaseViewModelOutput?
    let photosRepository: PhotosRepository
    let searchHistoryRepository: SearchHistoryRepository

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

        state.dropFirst()
            .setFailureType(to: FlickrPhotoError.self)
            .flatMap { [unowned self] state -> AnyPublisher<[ItemCollectionViewCellType], FlickrPhotoError> in
                switch state {
                case .searchResult(let term, let page):
                    searchHistoryRepository.saveSearchKeyword(searchKeyword: term)
                    return self.getData(for: term, page: page)
                case .searchHistory:
                    return self.getSearchHistory()

                }
            }.compactMap { $0 }
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { items in
                self.itemsForCollection.send(items)
            }).store(in: &cancelableSet)
    }
}


// MARK: - PhotosListViewModelInput
extension PhotosListViewModel: PhotosListViewModelInput {

    func search(for keyword: String) {
        itemsForCollection.value = []
        self.canLoadMore = true
        let searchHistoryRepository = UserDefaultSearchHistoryRepository()
        searchHistoryRepository.saveSearchKeyword(searchKeyword: keyword)
        state.send(.searchResult(term: keyword, page: 1))
    }

    func loadMoreData(_ page: Int) {
        if case .searchResult(let query, let pageValue) = state.value, pageValue <= page && canLoadMore == true {
            state.send(.searchResult(term: query, page: page))
        }
    }

    func getSearchHistory() -> AnyPublisher<[ItemCollectionViewCellType], FlickrPhotoError> {
        let searchHistoryRepository = UserDefaultSearchHistoryRepository()
        searchHistoryRepository.getSearchHistory()
        return searchHistoryRepository.searchHistorySubject.map { [unowned self] searchTerms -> [ItemCollectionViewCellType] in
            self.createItemsForCollection(searchTerms: searchTerms)
        }.eraseToAnyPublisher()
    }

    @objc
    private func changeInternetStatus(notification: Notification) {
        if notification.name == Notifications.Reachability.notConnected.name {
            output?.showError(title: "No Internet Connection", subtitle: "No Internet Conncection")
            emptyPlaceHolder.send(.noInternetConnection)
        } else {
            emptyPlaceHolder.send(.startSearch)
        }
    }
}

// MARK: Setup

extension PhotosListViewModel {

    private func getData(for query: String, page: Int) -> AnyPublisher<[ItemCollectionViewCellType], FlickrPhotoError> {

        output?.showLoading()
        canLoadMore = false

        return try! photosRepository.photos(for: query, page: page).compactMap {$0}.map { [unowned self] searchResult ->  [ItemCollectionViewCellType] in
            return self.handle(searchResult: searchResult)
        }.eraseToAnyPublisher()
    }

    func handle(searchResult: FlickrSearchResult) -> [ItemCollectionViewCellType] {
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
}

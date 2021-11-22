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
    var state: CurrentValueSubject<State, Never> { get set }
    var itemsForCollection: CurrentValueSubject<[ItemCollectionViewCellType], FlickrPhotoError> { get set }
}


enum State {
    case searchResult(term: String)
}

final class PhotosListViewModel {
    
    private weak var output: BaseViewModelOutput?
    let photosRepository: WebPhotosRepository
    
    fileprivate var page: Int = 1
    fileprivate var canLoadMore = true
    
    var itemsForCollection = CurrentValueSubject<[ItemCollectionViewCellType], FlickrPhotoError>([])
    var state: CurrentValueSubject<State, Never> = CurrentValueSubject<State, Never>(.searchResult(term: ""))
    var cancelableSet: Set<AnyCancellable> =  Set<AnyCancellable>()
    
    init(output: BaseViewModelOutput, photosRepository: WebPhotosRepository = WebPhotosRepository()) {
        self.output = output
        self.photosRepository = photosRepository
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
            itemsForCollection.send(completion: .failure(FlickrPhotoError.noResults))
        } else {
            itemsForCollection.send(newItems)
        }
    }
    
    private func handleNoPhotos() {
        if  itemsForCollection.value.isEmpty {
            itemsForCollection.send(completion: .failure(FlickrPhotoError.noResults))
        }
    }
    
    private func createItemsForCollection(photosArray: [Photo]) -> [ItemCollectionViewCellType] {
        return photosArray.map { photo -> ItemCollectionViewCellType  in
                .photo(photo: photo)
        }
    }
}

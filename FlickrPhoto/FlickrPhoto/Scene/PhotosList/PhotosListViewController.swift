//
//  PhotosListViewController.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import UIKit
import Combine

class PhotosListViewController: UIViewController {


    // MARK: - Outlets
    private lazy var photosCollectionView: UICollectionView = createCollectionView()
    private let searchController = UISearchController(searchResultsController: nil)

    var viewModel: PhotosListViewModelInput?
    private(set) var collectionDataSource: PhotosCollectionViewDataSource?
    var cancelableSet = Set<AnyCancellable>()

    // MARK: - View lifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        setupNavigationBar()
        setupBindings()
        getSearchHistory()
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(photosCollectionView)
        NSLayoutConstraint.activate([
            photosCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photosCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photosCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            photosCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        navigationItem.title = "Fliker Photos"
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()

        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.hidesBarsOnSwipe = true
    }

    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 90, height: 90)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.registerCell(type: PhotoCollectionCell.self)
        collectionView.registerCell(type: SearchHistoryCollectionCell.self)
        collectionView.register(HeaderCollectionCell.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderCollectionCell.identifier)
        collectionView.tag = 1
        collectionView.backgroundColor = .white
        return collectionView
    }

    private func setupSearchController() {
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = .black
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Write Keyword to search"
        definesPresentationContext = true
    }

    private func setupBindings() {
        viewModel?.itemsForCollection.sink(receiveCompletion: { [unowned self] completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                updateData(error: error)
            }
        }, receiveValue: { [unowned self] itemsForCollection in
            self.updateData(itemsForCollection: itemsForCollection)
        }).store(in: &cancelableSet)

        viewModel?.state.removeDuplicates().sink(receiveValue: { [unowned self] _  in
            self.clearCollection()
        }).store(in: &cancelableSet)

        viewModel?.emptyPlaceHolder.sink { [unowned self] emptyPlaceHolderType in
            self.emptyState(emptyPlaceHolderType: emptyPlaceHolderType)
        }.store(in: &cancelableSet)
    }

    private func emptyState(emptyPlaceHolderType: EmptyPlaceHolderType) {
        clearCollection()
        photosCollectionView.setEmptyView(emptyPlaceHolderType: emptyPlaceHolderType, completionBlock: { [weak self] in
            self?.search()
        })
    }

    private func updateData(error: Error) {
        switch error as? FlickrPhotoError {
        case .noResults:
            emptyState(emptyPlaceHolderType: .noResults)
        case .noInternetConnection:
            emptyState(emptyPlaceHolderType: .noInternetConnection)
        default:
            emptyState(emptyPlaceHolderType: .error(message: error.localizedDescription))
        }
    }

    private func updateData(itemsForCollection: [ItemCollectionViewCellType]) {

       if case let .searchResult(term, _) = viewModel?.state.value {
            searchController.searchBar.text = term
        }

        guard !itemsForCollection.isEmpty else {
            showReadyToSearch()
            return
        }

        if collectionDataSource == nil {
            photosCollectionView.restore()
            collectionDataSource = PhotosCollectionViewDataSource(viewModelInput: viewModel, itemsForCollection: itemsForCollection)
            photosCollectionView.dataSource = collectionDataSource
            photosCollectionView.delegate = collectionDataSource
            photosCollectionView.reloadData()
        } else {
            let fromIndex = collectionDataSource?.itemsForCollection.count ?? 0
            collectionDataSource?.itemsForCollection.append(contentsOf: itemsForCollection)
            let toIndex = collectionDataSource?.itemsForCollection.count ?? 0

            guard fromIndex < toIndex else { return }
            let indexes = (fromIndex ..< toIndex).map { row -> IndexPath in
                return IndexPath(row: row, section: 0)
            }

            photosCollectionView.performBatchUpdates {
                photosCollectionView.insertItems(at: indexes)
            }
        }
    }


    private func search() {
        if let text = searchController.searchBar.text, !text.isEmpty, text.count >= 3 {
            clearCollection()
            viewModel?.state.send(.searchResult(term: text, page: 1))
        }
    }

    private func getSearchHistory() {
        clearCollection()
        viewModel?.state.send(.searchHistory)
    }


    private func clearCollection() {
        collectionDataSource = nil
        photosCollectionView.dataSource = nil
        photosCollectionView.dataSource = nil
        photosCollectionView.reloadData()
    }
    private func showReadyToSearch() {
        photosCollectionView.setEmptyView(emptyPlaceHolderType: .startSearch, completionBlock: { [weak self] in
            self?.searchController.isActive = true
        })
    }
}

// MARK: UISearchBarDelegate
extension PhotosListViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        getSearchHistory()
    }
}

extension PhotosListViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchController.dismiss(animated: true)
        getSearchHistory()
        return true
    }
}

// MARK: UISearchControllerDelegate
extension PhotosListViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
            searchController.searchBar.becomeFirstResponder()
            getSearchHistory()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        search()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            getSearchHistory()
        }
    }
}

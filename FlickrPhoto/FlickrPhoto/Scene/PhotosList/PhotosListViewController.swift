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
        setupNavigationBar()
        setupSearchController()
        setupBindings()
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
        appearance.backgroundColor = UIColor.lightGray
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
        collectionView.tag = 1
        collectionView.backgroundColor = .white
        return collectionView
    }
    
    private func setupSearchController() {
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Type Keyword to search"
        definesPresentationContext = true
    }
    
    private func setupBindings(){
        viewModel?.itemsForCollection.sink(receiveCompletion: {completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                print("error \(error)")
            }
        }, receiveValue: { [unowned self] itemsForCollection in
            self.updateData(itemsForCollection: itemsForCollection)
        }).store(in: &cancelableSet)

        viewModel?.state.sink { [unowned self] state in
            self.clearCollection()
        }.store(in: &cancelableSet)
    }

    private func updateData(itemsForCollection: [ItemCollectionViewCellType]) {
        // reset term text to searchBar in case it removed
        if case let .searchResult(term) = viewModel?.state.value {
            searchController.searchBar.text = term
        }


        // Reload the collectionView
        if collectionDataSource == nil {
            collectionDataSource = PhotosCollectionViewDataSource(viewModelInput: viewModel, itemsForCollection: itemsForCollection)
            photosCollectionView.dataSource = collectionDataSource
            photosCollectionView.delegate = collectionDataSource
            photosCollectionView.reloadData()
        } else {

            // Reload only the updated cells

            //Get the inserted new cells
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
    
    private func clearCollection() {
        collectionDataSource = nil
        photosCollectionView.dataSource = nil
        photosCollectionView.dataSource = nil
        photosCollectionView.reloadData()
    }
}

// MARK: UISearchBarDelegate
extension PhotosListViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

extension PhotosListViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchController.dismiss(animated: true)
        return true
    }
}

// MARK: UISearchControllerDelegate
extension PhotosListViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
            searchController.searchBar.becomeFirstResponder()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text, !text.isEmpty, text.count >= 3 {
            viewModel?.search(for: text)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
        }
    }
}

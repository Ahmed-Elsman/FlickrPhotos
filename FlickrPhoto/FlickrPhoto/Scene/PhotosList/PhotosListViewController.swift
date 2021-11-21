//
//  PhotosListViewController.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import UIKit

class PhotosListViewController: UIViewController {

    // MARK: - Outlets
    private lazy var photosCollectionView: UICollectionView = createCollectionView()
    
    // MARK: - View lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .yellow
    }
    
    
    // MARK: - Setup UI
    
    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 82, height: 82)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.registerCell(type: PhotoCollectionCell.self)
        collectionView.tag = 1
        collectionView.backgroundColor = .white
        return collectionView
    }
}

//
//  PhotosListBuilder.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import Foundation

struct PhotosListBuilder {
    
    static func viewController() -> PhotosListViewController {
        let viewController: PhotosListViewController = PhotosListViewController()
        viewController.viewModel = PhotosListViewModel(output: viewController)
        return viewController
    }
}

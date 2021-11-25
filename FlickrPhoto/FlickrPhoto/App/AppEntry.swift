//
//  AppEntry.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import UIKit

struct AppEntry {

    func initFirstScene(window: UIWindow) {
        window.rootViewController = UINavigationController(rootViewController: PhotosListBuilder.viewController())
        window.makeKeyAndVisible()
    }
}

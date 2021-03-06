//
//  SceneDelegate.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        Reachability.shared.startNetworkReachabilityObserver()
        window = UIWindow(windowScene: windowScene)
        AppEntry().initFirstScene(window: window!)
    }
}

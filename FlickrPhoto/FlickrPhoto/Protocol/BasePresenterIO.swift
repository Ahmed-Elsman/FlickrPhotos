//
//  BasePresenterIO.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import UIKit
import SwiftMessages

protocol BaseDisplayLogic: AnyObject {
    func handle(error: FlickrPhotoError)
    func showError(error: Error)
    func showError(title: String, subtitle: String?)
    func showSuccess(title: String, subtitle: String?)
}

protocol Loading {
    func showLoading()
    func hideLoading()
}

protocol BaseViewModelOutput: BaseDisplayLogic, Loading { }

extension BaseDisplayLogic where Self: UIViewController {
    
    func handle(error: FlickrPhotoError) {
        showError(error: error)
    }
    
    func showError(error: Error) {
        showError(title: "Error Found", subtitle: error.localizedDescription)
    }
    
    func showError(title: String, subtitle: String?) {
        showAlert(title: title, subtitle: subtitle, theme: .error)
    }
    
    func showSuccess(title: String, subtitle: String?) {
        showAlert(title: title, subtitle: subtitle, theme: .success)
    }
    
    func showAlert(title: String, subtitle: String?, theme: Theme) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(theme)
        view.button?.isHidden = true
        view.configureContent(title: title, body: subtitle ?? "")
        
        var successConfig = SwiftMessages.defaultConfig
        successConfig.presentationStyle = .center
        successConfig.preferredStatusBarStyle = .lightContent
        successConfig.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        
        SwiftMessages.show(config: successConfig, view: view)
    }
}

extension UIViewController: BaseViewModelOutput {
    
    func showLoading() {
        DispatchQueue.main.async {
            self.view.showLoadingIndicator()
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.view.dismissLoadingIndicator()
        }
    }
}

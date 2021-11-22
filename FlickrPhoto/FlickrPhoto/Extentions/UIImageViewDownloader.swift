//
//  UIImageViewDownloader.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 22/11/2021.
//

import Kingfisher

extension UIImageView {

    func download(from path: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        guard let url = URL(string: path) else { return }
        kf.indicatorType = .activity
        kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeHolderImage"),
            options: [
                .transition(.fade(0.1)),
                .memoryCacheExpiration(.seconds(200)),
                .diskCacheExpiration(.seconds(200))
            ])
    }
}

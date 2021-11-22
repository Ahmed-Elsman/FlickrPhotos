//
//  PhotoCollectionCell.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 21/11/2021.
//

import UIKit

final class PhotoCollectionCell: UICollectionViewCell, CellReusable {

     let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image  = UIImage(named: "placeHolderImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.kf.cancelDownloadTask()
        photoImageView.image = nil
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(photoImageView)

        NSLayoutConstraint.activate([
            photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoImageView.topAnchor.constraint(equalTo: topAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }

    func configCell(photo: Photo) {
        photoImageView.download(from: photo.imagePath, contentMode: .scaleAspectFit)
    }
}


#warning("add this in another file")
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

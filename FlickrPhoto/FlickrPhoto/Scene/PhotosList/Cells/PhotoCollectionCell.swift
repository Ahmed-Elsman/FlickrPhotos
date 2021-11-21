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
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellViews()
    }
    
    private func setupCellViews() {
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
    }
}

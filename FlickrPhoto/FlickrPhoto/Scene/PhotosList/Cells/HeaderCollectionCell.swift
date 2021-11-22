//
//  HeaderCollectionViewCell.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 22/11/2021.
//

import UIKit

final class HeaderCollectionCell: UICollectionReusableView, CellReusable {

    private var heaerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    private func setupViews() {
        addSubview(heaerLabel)

        NSLayoutConstraint.activate([
            heaerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            heaerLabel.topAnchor.constraint(equalTo: topAnchor),
            heaerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            heaerLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        backgroundColor = .secondarySystemBackground
    }

    func configCell(searchTerm: String) {
        heaerLabel.text = searchTerm
    }

}

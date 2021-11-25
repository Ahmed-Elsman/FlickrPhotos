//
//  SearchHistoryCollectionCell.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 22/11/2021.
//

import UIKit

final class SearchHistoryCollectionCell: UICollectionViewCell, CellReusable {

    private var searchKeywordLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
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
        backgroundColor = .systemBackground
    }

    private func setupViews() {
        addSubview(searchKeywordLabel)

        NSLayoutConstraint.activate([
            searchKeywordLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchKeywordLabel.topAnchor.constraint(equalTo: topAnchor),
            searchKeywordLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            searchKeywordLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func configCell(searchTerm: String) {
        searchKeywordLabel.text = searchTerm
    }

}

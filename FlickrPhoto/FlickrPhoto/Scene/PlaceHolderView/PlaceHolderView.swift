//
//  PlaceHolderView.swift
//  FlickrPhoto
//
//  Created by Ahmed Elsman on 22/11/2021.
//

import UIKit
import Combine

enum EmptyPlaceHolderType {
    case noInternetConnection
    case noResults
    case startSearch
    case error(message: String)
}

final class EmptyPlaceHolderView: UIView {
    
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var emptyPlaceHolderType: EmptyPlaceHolderType = .noInternetConnection
    
    private lazy var logoImageView: UIImageView = createImageView()
    
    private lazy var titleLabel: UILabel = createTitleLabel()
    private lazy var detailsLabel: UILabel = createDetailsLabel()
    
    
    private lazy var contentStackView: UIStackView = createContentStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        $emptyPlaceHolderType.sink { [unowned self] emptyPlaceHolderType in
            switch emptyPlaceHolderType {
            case .noInternetConnection:
                self.titleLabel.text = "No Internet Connection"
                self.detailsLabel.text = "No Internet Connection Please Check Connection Again"
                self.logoImageView.image = UIImage(named: "noNetworkSignal")?.withTintColor(.secondarySystemBackground, renderingMode: .alwaysOriginal)
            case .noResults:
                self.titleLabel.text = "No Photos Found"
                self.detailsLabel.text = "No Photos Found Please write New Keyword"
                self.logoImageView.image = UIImage(named: "noImage")?.withTintColor(.secondarySystemBackground, renderingMode: .alwaysOriginal)
            case .startSearch:
                self.titleLabel.text = "Lets Start Searching"
                self.detailsLabel.text = "Write Keyword in search bar to start searching"
                self.logoImageView.image = UIImage(named: "magGlass")?.withTintColor(.secondarySystemBackground, renderingMode: .alwaysOriginal)
            case .error(let errorMessage):
                self.titleLabel.text = "Error Found"
                self.detailsLabel.text = "Error Found \(errorMessage)"
                self.logoImageView.image = UIImage(named: "warning")?.withTintColor(.secondarySystemBackground, renderingMode: .alwaysOriginal)
            }
        }.store(in: &subscriptions)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(contentStackView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    // MARK: - Setup UI
    
    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 20)
        ])
        label.tag = LoadingTags.Placeholder.mainTitle.rawValue
        return label
    }
    
    private func createDetailsLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 20)
        ])
        label.tag = LoadingTags.Placeholder.description.rawValue
        return label
    }
    
    private func createContentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.spacing =  5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(logoImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(detailsLabel)
        stackView.setCustomSpacing(30, after: detailsLabel)
        return stackView
    }
    
    private func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 60)
        ])
        return imageView
    }
}


extension UICollectionView {
    
    func setEmptyView(emptyPlaceHolderType: EmptyPlaceHolderType, completionBlock: (() -> Void)? = nil) {
        let frame = CGRect(x: center.x, y: center.y, width: bounds.size.width, height: bounds.size.height)
        let emptyPlaceHolderView = EmptyPlaceHolderView(frame: frame)
        emptyPlaceHolderView.translatesAutoresizingMaskIntoConstraints = false
        emptyPlaceHolderView.emptyPlaceHolderType = emptyPlaceHolderType
        backgroundView = emptyPlaceHolderView
        NSLayoutConstraint.activate([
            emptyPlaceHolderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyPlaceHolderView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyPlaceHolderView.widthAnchor.constraint(equalTo: widthAnchor),
            emptyPlaceHolderView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func restore() {
        backgroundView = nil
    }
}

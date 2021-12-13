//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

class CarouselCell: UICollectionViewCell {
    // MARK: - SubViews
    private lazy var imageView = UIImageView()
    private lazy var textLabel = UILabel()
    let screenSize: CGRect = UIScreen.main.bounds
    
    
    // MARK: - Properties
    static let cellId = "CarouselCell"
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

// MARK: - Setups
private extension CarouselCell {
    func setupUI() {
        backgroundColor = .clear
        
        addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height * 0.2)
//        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        imageView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
//        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.contentMode = .scaleAspectFill

        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16).isActive = true
        textLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        textLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.font = .systemFont(ofSize: 18)
        textLabel.textColor = .white
    }
}

// MARK: - Public
extension CarouselCell {
    public func configure(image: UIImage?, text: String) {
        imageView.image = image
        textLabel.text = text
    }
}

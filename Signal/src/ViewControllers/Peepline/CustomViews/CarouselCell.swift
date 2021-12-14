//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

class CarouselCell: UICollectionViewCell {
    // MARK: - SubViews
    private lazy var imageView = UIImageView()
    private lazy var textLabel = UILabel()
    private lazy var titleLabel = UILabel()
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
        imageView.frame = CGRect(x: 0, y: 20, width: screenSize.width, height: screenSize.height * 0.5)
        imageView.contentMode = .scaleAspectFill
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 35).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textColor = .black

        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        textLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        textLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.font = .systemFont(ofSize: 18)
        textLabel.textColor = UIColor(rgbHex: 0x9A9A9A)
    }
}

// MARK: - Public
extension CarouselCell {
    public func configure(image: UIImage?, text: String, title: String) {
        imageView.image = image
        textLabel.text = text
        titleLabel.text = title
    }
}

//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit

protocol CarouselViewDelegate: class {
    func currentPageDidChange(to page: Int)
}

struct CarouselData {
    let image: UIImage?
    let text: String
    let title: String
}

class CarouselView: UIView {
    // MARK: - Subviews
        
    private lazy var carouselCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.dataSource = self
        collection.delegate = self
        collection.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.cellId)
        
        return collection
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = UIColor(rgbHex: 0xE6E6E6)
        pageControl.currentPageIndicatorTintColor = UIColor(rgbHex: 0x2D6EB0)
        pageControl.addTarget(self, action: #selector(self.pageControlSelectionAction(_:)), for: .touchUpInside)
        return pageControl
    }()
    
    @objc func pageControlSelectionAction(_ sender: UIPageControl) {
        let page: Int? = sender.currentPage
        pageControl.updatePageDots()
        changePageFrame(page: page ?? 0)
    }
    
    private func changePageFrame(page: Int) {
        var frame: CGRect = self.carouselCollectionView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        self.carouselCollectionView.scrollRectToVisible(frame, animated: true)
    }
    
    public func changePageToIndex(page: Int) {
        currentPage = page
        changePageFrame(page: page)
    }
    
    // MARK: - Properties
    
    private var pages: Int
    private weak var delegate: CarouselViewDelegate?
    let screenSize: CGRect = UIScreen.main.bounds
    private var carouselData = [CarouselData]()
    public var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            pageControl.updatePageDots()
            delegate?.currentPageDidChange(to: currentPage)
        }
    }
    
    // MARK: - Initializers
    
    init(pages: Int, delegate: CarouselViewDelegate?) {
        self.pages = pages
        self.delegate = delegate
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setups

private extension CarouselView {
    func setupUI() {
        setupCollectionView()
        setupPageControl()
    }
    
    func setupCollectionView() {
        let carouselLayout = UICollectionViewFlowLayout()
        carouselLayout.scrollDirection = .horizontal
        carouselLayout.itemSize = .init(width: screenSize.width, height: screenSize.height * 0.7)
        carouselLayout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        carouselLayout.minimumLineSpacing = 0
        carouselCollectionView.collectionViewLayout = carouselLayout
        
        addSubview(carouselCollectionView)
        carouselCollectionView.translatesAutoresizingMaskIntoConstraints = false
        carouselCollectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        carouselCollectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        carouselCollectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        carouselCollectionView.heightAnchor.constraint(equalToConstant: screenSize.height * 0.7).isActive = true
    }
    
    func setupPageControl() {
        addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.topAnchor.constraint(equalTo: carouselCollectionView.bottomAnchor, constant: 10).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pageControl.widthAnchor.constraint(equalToConstant: 300).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        pageControl.numberOfPages = pages
    }
}

// MARK: - UICollectionViewDataSource

extension CarouselView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return carouselData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.cellId, for: indexPath) as? CarouselCell else { return UICollectionViewCell() }
        
        let image = carouselData[indexPath.row].image
        let text = carouselData[indexPath.row].text
        let title = carouselData[indexPath.row].title
        
        cell.configure(image: image, text: text, title: title)
        
        return cell
    }
}

// MARK: - UICollectionView Delegate

extension CarouselView: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = getCurrentPage()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        currentPage = getCurrentPage()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = getCurrentPage()
    }
}

// MARK: - Public

extension CarouselView {
    public func configureView(with data: [CarouselData]) {
        let carouselLayout = UICollectionViewFlowLayout()
        let window = UIApplication.shared.keyWindow
       
        carouselLayout.scrollDirection = .horizontal
        carouselLayout.itemSize = .init(width: screenSize.width, height: screenSize.height * 0.7)
        carouselLayout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        carouselLayout.minimumLineSpacing = 0
        carouselCollectionView.collectionViewLayout = carouselLayout
        
        carouselData = data
        carouselCollectionView.reloadData()
    }
}

// MARKK: - Helpers

private extension CarouselView {
    func getCurrentPage() -> Int {
        let visibleRect = CGRect(origin: carouselCollectionView.contentOffset, size: carouselCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = carouselCollectionView.indexPathForItem(at: visiblePoint) {
            return visibleIndexPath.row
        }
        
        return currentPage
    }
}

extension UIPageControl {
    func customPageControl() {
        for (pageIndex, dotView) in self.subviews.enumerated() {
            if self.currentPage == pageIndex {
                dotView.layer.cornerRadius = 0
                dotView.transform = CGAffineTransform(scaleX: 6, y: 1.5)
            } else {
                dotView.layer.cornerRadius = 0
                dotView.transform = CGAffineTransform(scaleX: 4, y: 1.5)
            }
        }
    }
    
  
    func updatePageDots() {
        var image: UIImage!
        
        for index in (0...numberOfPages - 1) {
            if self.currentPage == index {
                image = UIImage(named: "activeDot")!
                    .imageResize(sizeChange: CGSize(width: 50, height: 7))
            } else {
                image = UIImage(named: "inActiveDot")!
                    .imageResize(sizeChange: CGSize(width: 20, height: 7))
            }
            
            if #available(iOS 14.0, *) {
                self.setIndicatorImage(image, forPage: index)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

extension UIImage {
  func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
    guard let ctx = UIGraphicsGetCurrentContext(), let image = cgImage else { return self }
    defer { UIGraphicsEndImageContext() }
        
    let rect = CGRect(origin: .zero, size: size)
    ctx.setFillColor(color.cgColor)
    ctx.fill(rect)
    ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
    ctx.draw(image, in: rect)
        
    return UIGraphicsGetImageFromCurrentImageContext() ?? self
  }
    
    public func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if let radius = radius, radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func imageResize (sizeChange:CGSize)-> UIImage{

        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen

        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
}

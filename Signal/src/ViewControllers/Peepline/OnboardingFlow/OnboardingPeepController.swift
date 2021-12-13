//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import UIKit

@objc
public class OnboardingPeepController: UIViewController {
    // MARK: - Subviews
    private var carouselView: CarouselView?
    
    // MARK: - Properties
    let screenSize: CGRect = UIScreen.main.bounds
    var carouselData = [CarouselData]()
        
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
        view.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0).isActive = true
        
        carouselView = CarouselView(pages: 3, delegate: self)
        carouselData.append(.init(image: UIImage(named: "onboarding_boxes"), text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"))
        carouselData.append(.init(image: UIImage(named: "onboarding_girl"), text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"))
        carouselData.append(.init(image: UIImage(named: "onboarding_network"), text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"))

        setupUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        carouselView?.configureView(with: carouselData)
    }
}

// MARK: - Setups

private extension OnboardingPeepController {
    func setupUI() {

        guard let carouselView = carouselView else { return }
        view.addSubview(carouselView)
        carouselView.translatesAutoresizingMaskIntoConstraints = false
        carouselView.autoPinEdges(toEdgesOf: view)
    }
}

extension OnboardingPeepController: CarouselViewDelegate {
    func currentPageDidChange(to page: Int) {
        UIView.animate(withDuration: 0.7) {
//            self.view.backgroundColor = self.backgroundColors[page]
        }
    }
}

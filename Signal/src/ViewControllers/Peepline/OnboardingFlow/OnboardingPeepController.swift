//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import UIKit

@objc
public class OnboardingPeepController: OnboardingBaseViewController {
    // MARK: - Subviews
    private var carouselView: CarouselView?
    
    // MARK: - Properties
    let screenSize: CGRect = UIScreen.main.bounds
    var carouselData = [CarouselData]()
        
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white

        carouselView = CarouselView(pages: 3, delegate: self)
        carouselData.append(.init(image: UIImage(named: "onboarding_boxes"), text: "Bring you and your Peeps into a safe & secure world away from big brothers", title: "Invite"))
        carouselData.append(.init(image: UIImage(named: "onboarding_network"), text: "It's your private circle or your own trusted peeps with those that matter most to you", title: "Connect"))
        carouselData.append(.init(image: UIImage(named: "onboarding_girl"), text: "Secure exchanges with end-to-end encryption to keep out prying eyes", title: "Share"))

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
        carouselView.autoPinEdgesToSuperviewEdges(withInsets: UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0))
        
        let continueButton = self.primaryButton(title: "Next")
        view.addSubview(continueButton)
        
        continueButton.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 20)
        continueButton.autoHCenterInSuperview()
    }
    
    func primaryButton(title: String ) -> OWSFlatButton {
        let button = OWSFlatButton.button(
            title: title,
            font: UIFont.ows_dynamicTypeBodyClamped.ows_semibold,
            titleColor: .white,
            backgroundColor: .ows_accentBlue,
            target: self,
            selector: #selector(continuePressed))
        button.button.layer.cornerRadius = 25
        button.contentEdgeInsets = UIEdgeInsets(hMargin: 4, vMargin: 14)
        button.autoSetDimension(.width, toSize: 280)
        return button
    }
    
    @objc func continuePressed() {
        switch carouselView?.currentPage {
        case 0:
            carouselView?.changePageToIndex(page: 1)
            return
        case 1:
            carouselView?.changePageToIndex(page: 2)
            return
        case 2:
//            let vc = CreateAccountViewController(onboardingController: self.onboardingController)
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true, completion: nil)
            onboardingController.onboardingPeeplineDidComplete(viewController: self)
            return
        default:
            return
        }
    }
}

extension OnboardingPeepController: CarouselViewDelegate {
    func currentPageDidChange(to page: Int) {
        UIView.animate(withDuration: 0.7) {
//            self.view.backgroundColor = self.backgroundColors[page]
        }
    }
}

//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import UIKit

@objc
public class CreateAccountViewController: OnboardingBaseViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        
        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "create_account")
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        backgroundImageView.autoPinEdgesToSuperviewEdges()
        
        let alreadyAccountLabel = UILabel()
        alreadyAccountLabel.text = "I have an Account"
        alreadyAccountLabel.numberOfLines = 0
        alreadyAccountLabel.textAlignment = .center
        alreadyAccountLabel.font = .systemFont(ofSize: 18)
        alreadyAccountLabel.textColor = .white
        view.addSubview(alreadyAccountLabel)
        alreadyAccountLabel.translatesAutoresizingMaskIntoConstraints = false
        alreadyAccountLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 45)
        alreadyAccountLabel.autoHCenterInSuperview()
        alreadyAccountLabel.isUserInteractionEnabled = true
        alreadyAccountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(alreadyAccountPressed)))
        
        let continueButton = self.primaryButton(title: "Create a New Account")
        view.addSubview(continueButton)
        
        continueButton.autoPinEdge(.bottom, to: .top, of: alreadyAccountLabel, withOffset: -20)
        continueButton.autoHCenterInSuperview()
        
        let titleLabel = UILabel()
        titleLabel.text = "Connect People\n& Be Personal"
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 26)
        titleLabel.textColor = .white
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.autoPinEdge(.bottom, to: .top, of: continueButton, withOffset: -60)
        titleLabel.autoHCenterInSuperview()
    }
    
    func primaryButton(title: String ) -> OWSFlatButton {
        let button = OWSFlatButton.button(
            title: title,
            font: UIFont.ows_dynamicTypeBodyClamped.ows_semibold,
            titleColor: .ows_accentBlue,
            backgroundColor: .white,
            target: self,
            selector: #selector(continuePressed))
        button.button.layer.cornerRadius = 25
        button.contentEdgeInsets = UIEdgeInsets(hMargin: 4, vMargin: 14)
        button.autoSetDimension(.width, toSize: 280)
        return button
    }
    
    @objc func continuePressed() {
        onboardingController.onboardingCreateAccountDidComplete(viewController: self)
    }
    
    @objc func alreadyAccountPressed() {
        onboardingController.onboardingCreateAccountDidComplete(viewController: self)
    }
}

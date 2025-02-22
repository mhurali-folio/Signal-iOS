//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import UIKit
import SafariServices

@objc(OWSPinSetupViewController)
public class PinSetupViewController: OWSViewController {

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme.primaryTextColor
        label.font = UIFont.ows_dynamicTypeTitle1Clamped.ows_semibold
        label.textAlignment = .center
        label.text = titleText
        return label
    }()

    lazy private var explanationLabel: LinkingTextView = {
        let explanationLabel = LinkingTextView()
        let explanationText: String
        switch mode {
        case .creating:
            explanationText = NSLocalizedString("PIN_CREATION_EXPLANATION",
                                                comment: "The explanation in the 'pin creation' view.")
        case .recreating, .changing:
            explanationText = NSLocalizedString("PIN_CREATION_RECREATION_EXPLANATION",
                                                comment: "The re-creation explanation in the 'pin creation' view.")
        case .confirming:
            explanationText = NSLocalizedString("PIN_CREATION_CONFIRMATION_EXPLANATION",
                                                comment: "The explanation of confirmation in the 'pin creation' view.")
        }

        // The font is too long to fit wih dynamic type. Design is looking into
        // how to design this page to fit dyanmic type. In the meantime, we have
        // to pin the font size.
        let explanationLabelFont = UIFont.systemFont(ofSize: 15)

        let attributedString = NSMutableAttributedString(
            string: explanationText,
            attributes: [
                .font: explanationLabelFont,
                .foregroundColor: Theme.secondaryTextAndIconColor
            ]
        )

        if !mode.isConfirming {
            explanationLabel.isUserInteractionEnabled = true
            attributedString.append("  ")
            attributedString.append(
                CommonStrings.learnMore,
                attributes: [
                    .link: URL(string: "https://support.signal.org/hc/articles/360007059792")!,
                    .font: explanationLabelFont
                ]
            )
        }
        explanationLabel.attributedText = attributedString
        explanationLabel.textAlignment = .center
        explanationLabel.accessibilityIdentifier = "pinCreation.explanationLabel"
        return explanationLabel
    }()

    private let topSpacer = UIView.vStretchingSpacer()
    private var proportionalSpacerConstraint: NSLayoutConstraint?

    private let pinTextField: UITextField = {
        let pinTextField = UITextField()
        pinTextField.textAlignment = .center
        pinTextField.textColor = Theme.primaryTextColor

        let font = UIFont.systemFont(ofSize: 17)
        pinTextField.font = font
        pinTextField.autoSetDimension(.height, toSize: font.lineHeight + 2 * 8.0)

        pinTextField.textContentType = .password
        pinTextField.isSecureTextEntry = true
        pinTextField.defaultTextAttributes.updateValue(5, forKey: .kern)
        pinTextField.keyboardAppearance = Theme.keyboardAppearance
        pinTextField.accessibilityIdentifier = "pinCreation.pinTextField"
        return pinTextField
    }()

    private lazy var pinTypeToggle: OWSFlatButton = {
        let pinTypeToggle = OWSFlatButton()
        pinTypeToggle.setTitle(font: .ows_dynamicTypeSubheadlineClamped, titleColor: Theme.accentBlueColor)
        pinTypeToggle.setBackgroundColors(upColor: .clear)

        pinTypeToggle.enableMultilineLabel()
        pinTypeToggle.button.clipsToBounds = true
        pinTypeToggle.button.layer.cornerRadius = 8
        pinTypeToggle.contentEdgeInsets = UIEdgeInsets(hMargin: 4, vMargin: 8)

        pinTypeToggle.addTarget(target: self, selector: #selector(togglePinType))
        pinTypeToggle.accessibilityIdentifier = "pinCreation.pinTypeToggle"
        return pinTypeToggle
    }()

    private let nextButton: OWSFlatButton = {
        let nextButton = OWSFlatButton()
        nextButton.setTitle(
            title: CommonStrings.nextButton,
            font: UIFont.ows_dynamicTypeBodyClamped.ows_semibold,
            titleColor: .white)
        nextButton.setBackgroundColors(upColor: .ows_accentBlue)

        nextButton.button.clipsToBounds = true
        nextButton.button.layer.cornerRadius = 14
        nextButton.contentEdgeInsets = UIEdgeInsets(hMargin: 4, vMargin: 14)

        nextButton.addTarget(target: self, selector: #selector(nextPressed))
        nextButton.accessibilityIdentifier = "pinCreation.nextButton"
        return nextButton
    }()

    private let validationWarningLabel: UILabel = {
        let validationWarningLabel = UILabel()
        validationWarningLabel.textColor = .ows_accentRed
        validationWarningLabel.textAlignment = .center
        validationWarningLabel.font = UIFont.ows_dynamicTypeFootnoteClamped
        validationWarningLabel.numberOfLines = 0
        validationWarningLabel.accessibilityIdentifier = "pinCreation.validationWarningLabel"
        return validationWarningLabel
    }()

    private let recommendationLabel: UILabel = {
        let recommendationLabel = UILabel()
        recommendationLabel.textColor = Theme.secondaryTextAndIconColor
        recommendationLabel.textAlignment = .center
        recommendationLabel.font = UIFont.ows_dynamicTypeFootnoteClamped
        recommendationLabel.numberOfLines = 0
        recommendationLabel.accessibilityIdentifier = "pinCreation.recommendationLabel"
        return recommendationLabel
    }()

    private let backButton: UIButton = {
        let topButtonImage = CurrentAppContext().isRTL ? #imageLiteral(resourceName: "NavBarBackRTL") : #imageLiteral(resourceName: "NavBarBack")
        let backButton = UIButton.withTemplateImage(topButtonImage, tintColor: Theme.secondaryTextAndIconColor)

        backButton.autoSetDimensions(to: CGSize(square: 40))
        backButton.addTarget(self, action: #selector(navigateBack), for: .touchUpInside)
        return backButton
    }()

    private let moreButton: UIButton = {
        let moreButton = UIButton.withTemplateImageName("more-horiz-24", tintColor: Theme.primaryIconColor)
        moreButton.autoSetDimensions(to: CGSize(square: 40))
        moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
        return moreButton
    }()

    private lazy var pinStrokeNormal = pinTextField.addBottomStroke()
    private lazy var pinStrokeError = pinTextField.addBottomStroke(color: .ows_accentRed, strokeWidth: 2)

    enum Mode {
        case creating
        case recreating
        case changing
        case confirming(pinToMatch: String)

        var isChanging: Bool {
            guard case .changing = self else { return false }
            return true
        }

        var isConfirming: Bool {
            guard case .confirming = self else { return false }
            return true
        }
    }
    private let mode: Mode

    private let initialMode: Mode

    enum ValidationState {
        case valid
        case tooShort
        case mismatch
        case weak

        var isInvalid: Bool {
            return self != .valid
        }
    }
    private var validationState: ValidationState = .valid {
        didSet {
            updateValidationWarnings()
        }
    }

    private var pinType: KeyBackupService.PinType {
        didSet {
            updatePinType()
        }
    }

    // Called once pin setup has finished. Error will be nil upon success
    private let completionHandler: (PinSetupViewController, Error?) -> Void

    private let enableRegistrationLock: Bool

    init(
        mode: Mode,
        initialMode: Mode? = nil,
        pinType: KeyBackupService.PinType = .numeric,
        enableRegistrationLock: Bool = OWS2FAManager.shared.isRegistrationLockEnabled,
        completionHandler: @escaping (PinSetupViewController, Error?) -> Void
    ) {
        assert(TSAccountManager.shared.isRegisteredPrimaryDevice)
        self.mode = mode
        self.initialMode = initialMode ?? mode
        self.pinType = pinType
        self.enableRegistrationLock = enableRegistrationLock
        self.completionHandler = completionHandler
        super.init()

        if case .confirming = self.initialMode {
            owsFailDebug("pin setup flow should never start in the confirming state")
        }
    }

    @objc
    class func creatingRegistrationLock(completionHandler: @escaping (PinSetupViewController, Error?) -> Void) -> PinSetupViewController {
        return .init(mode: .creating, enableRegistrationLock: true, completionHandler: completionHandler)
    }

    @objc
    class func creating(completionHandler: @escaping (PinSetupViewController, Error?) -> Void) -> PinSetupViewController {
        return .init(mode: .creating, completionHandler: completionHandler)
    }

    @objc
    class func changing(completionHandler: @escaping (PinSetupViewController, Error?) -> Void) -> PinSetupViewController {
        return .init(mode: .changing, completionHandler: completionHandler)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shouldIgnoreKeyboardChanges = false

        if let navigationBar = navigationController?.navigationBar as? OWSNavigationBar {
            navigationBar.navbarBackgroundColorOverride = backgroundColor
            navigationBar.switchToStyle(.solid, animated: true)
        }

        // Hide the nav bar when not changing.
        navigationController?.setNavigationBarHidden(!initialMode.isChanging, animated: false)
        title = titleText

        let topMargin: CGFloat = navigationController?.isNavigationBarHidden == false ? 0 : 32
        let hMargin: CGFloat = UIDevice.current.isIPhone5OrShorter ? 13 : 26
        view.layoutMargins = UIEdgeInsets(top: topMargin, leading: hMargin, bottom: 0, trailing: hMargin)

        if navigationController?.isNavigationBarHidden == false {
            [backButton, moreButton, titleLabel].forEach { $0.isHidden = true }
        } else {
            // If we're in creating mode AND we're the rootViewController, don't allow going back
            if case .creating = mode, navigationController?.viewControllers.first == self {
                backButton.isHidden = true
            } else {
                backButton.isHidden = false
            }
            moreButton.isHidden = mode.isConfirming
            titleLabel.isHidden = false
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // TODO: Maybe do this in will appear, to avoid the keyboard sliding in when the view is pushed?
        pinTextField.becomeFirstResponder()
    }

    private var backgroundColor: UIColor {
        presentingViewController == nil ? Theme.backgroundColor : Theme.tableView2PresentedBackgroundColor
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shouldIgnoreKeyboardChanges = true

        if let navigationBar = navigationController?.navigationBar as? OWSNavigationBar {
            navigationBar.switchToStyle(.default, animated: true)
        }

        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.isDarkThemeEnabled ? .lightContent : .default
    }

    override public func loadView() {
        owsAssertDebug(navigationController != nil, "This view should always be presented in a nav controller")
        view = UIView()
        view.backgroundColor = backgroundColor

        view.addSubview(backButton)
        backButton.autoPinEdge(toSuperviewSafeArea: .top)
        backButton.autoPinEdge(toSuperviewSafeArea: .leading)

        view.addSubview(moreButton)
        moreButton.autoPinEdge(toSuperviewSafeArea: .top)
        moreButton.autoPinEdge(toSuperviewSafeArea: .trailing)

        let titleSpacer = SpacerView(preferredHeight: 12)
        let pinFieldSpacer = SpacerView(preferredHeight: 11)
        let bottomSpacer = SpacerView(preferredHeight: 10)
        let pinToggleSpacer = SpacerView(preferredHeight: 24)
        let buttonSpacer = SpacerView(preferredHeight: 32)

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            titleSpacer,
            explanationLabel,
            topSpacer,
            pinTextField,
            pinFieldSpacer,
            validationWarningLabel,
            recommendationLabel,
            bottomSpacer,
            pinTypeToggle,
            pinToggleSpacer,
            OnboardingBaseViewController.horizontallyWrap(primaryButton: nextButton),
            buttonSpacer
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        view.addSubview(stackView)

        stackView.autoPinEdges(toSuperviewMarginsExcludingEdge: .bottom)
        autoPinView(toBottomOfViewControllerOrKeyboard: stackView, avoidNotch: true)

        [pinTextField, validationWarningLabel, recommendationLabel].forEach {
            $0.autoSetDimension(.width, toSize: 227)
        }

        [titleLabel, explanationLabel, pinTextField, validationWarningLabel, recommendationLabel, pinTypeToggle, nextButton]
            .forEach { $0.setCompressionResistanceVerticalHigh() }

        // Reduce priority of compression resistance for the spacer views
        // The array index serves as an ambiguous layout tiebreaker
        [titleSpacer, pinFieldSpacer, bottomSpacer, pinToggleSpacer, buttonSpacer].enumerated().forEach {
            $0.element.setContentCompressionResistancePriority(.defaultHigh - .init($0.offset), for: .vertical)
        }

        // Bottom spacer is the stack view item that grows when there's extra space
        // Ensure whitespace is balanced, so inputs are vertically centered.
        bottomSpacer.setContentHuggingPriority(.init(100), for: .vertical)
        proportionalSpacerConstraint = topSpacer.autoMatch(.height, to: .height, of: bottomSpacer)
        updateValidationWarnings()
        updatePinType()

        // Pin text field
        pinTextField.delegate = self
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Don't allow interactive dismissal.
        if #available(iOS 13, *) {
            isModalInPresentation = true
        }
    }

    var titleText: String {
        if mode.isConfirming {
            return NSLocalizedString("PIN_CREATION_CONFIRM_TITLE", comment: "Title of the 'pin creation' confirmation view.")
        } else if case .recreating = initialMode {
            return NSLocalizedString("PIN_CREATION_RECREATION_TITLE", comment: "Title of the 'pin creation' recreation view.")
        } else if initialMode.isChanging {
            return NSLocalizedString("PIN_CREATION_CHANGING_TITLE", comment: "Title of the 'pin creation' recreation view.")
        } else {
            return NSLocalizedString("PIN_CREATION_TITLE", comment: "Title of the 'pin creation' view.")
        }
    }

    // MARK: - Events

    @objc func navigateBack() {
        Logger.info("")

        if case .recreating = mode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc
    func didTapMoreButton(_ sender: UIButton) {
        let actionSheet = ActionSheetController()
        actionSheet.addAction(OWSActionSheets.cancelAction)

        proportionalSpacerConstraint?.isActive = false
        let pinnedHeightConstraint = topSpacer.autoSetDimension(.height, toSize: topSpacer.height)

        let learnMoreAction = ActionSheetAction(
            title: NSLocalizedString(
                "PIN_CREATION_LEARN_MORE",
                comment: "Learn more action on the pin creation view"
            )
        ) { [weak self] _ in
            guard let self = self else { return }
            let vc = SFSafariViewController(url: URL(string: "https://support.signal.org/hc/articles/360007059792")!)
            self.present(vc, animated: true) {
                pinnedHeightConstraint.isActive = false
                self.proportionalSpacerConstraint?.isActive = true
            }
        }
        actionSheet.addAction(learnMoreAction)

        let skipAction = ActionSheetAction(
            title: NSLocalizedString(
                "PIN_CREATION_SKIP",
                comment: "Skip action on the pin creation view"
            )
        ) { [weak self] _ in
            guard let self = self else { return }
            Self.disablePinWithConfirmation(fromViewController: self).done { [weak self] pinDisabled in
                guard pinDisabled, let self = self else { return }
                self.completionHandler(self, nil)
                pinnedHeightConstraint.isActive = false
                self.proportionalSpacerConstraint?.isActive = true
            }.catch { [weak self] error in
                guard let self = self else { return }
                OWSActionSheets.showActionSheet(
                    title: NSLocalizedString("PIN_DISABLE_ERROR_TITLE",
                                             comment: "Error title indicating that the attempt to disable a PIN failed."),
                    message: NSLocalizedString("PIN_DISABLE_ERROR_MESSAGE",
                                               comment: "Error body indicating that the attempt to disable a PIN failed.")
                ) { _ in
                    self.completionHandler(self, error)
                    pinnedHeightConstraint.isActive = false
                    self.proportionalSpacerConstraint?.isActive = true
                }
            }
        }
        actionSheet.addAction(skipAction)

        presentActionSheet(actionSheet)
    }

    @objc func nextPressed() {
        Logger.info("")

        tryToContinue()
    }

    private func tryToContinue() {
        Logger.info("")

        guard let pin = pinTextField.text?.ows_stripped(), pin.count >= kMin2FAv2PinLength else {
            validationState = .tooShort
            return
        }

        if case .confirming(let pinToMatch) = mode, pinToMatch != pin {
            validationState = .mismatch
            return
        }

        if isWeakPin(pin) {
            validationState = .weak
            return
        }

        switch mode {
        case .creating, .changing, .recreating:
            let confirmingVC = PinSetupViewController(
                mode: .confirming(pinToMatch: pin),
                initialMode: initialMode,
                pinType: pinType,
                enableRegistrationLock: enableRegistrationLock,
                completionHandler: completionHandler
            )
            navigationController?.pushViewController(confirmingVC, animated: true)
        case .confirming:
            enable2FAAndContinue(withPin: pin)
        }
    }

    private func isWeakPin(_ pin: String) -> Bool {
        let normalizedPin = KeyBackupService.normalizePin(pin)

        // We only check numeric pins for weakness
        guard normalizedPin.digitsOnly() == normalizedPin else { return false }

        var allTheSame = true
        var forwardSequential = true
        var reverseSequential = true

        var previousWholeNumberValue: Int?
        for character in normalizedPin {
            guard let current = character.wholeNumberValue else {
                owsFailDebug("numeric pin unexpectedly contatined non-numeric characters")
                break
            }

            defer { previousWholeNumberValue = current }
            guard let previous = previousWholeNumberValue else { continue }

            if previous != current { allTheSame = false }
            if previous + 1 != current { forwardSequential = false }
            if previous - 1 != current { reverseSequential = false }

            if !allTheSame && !forwardSequential && !reverseSequential { break }
        }

        return allTheSame || forwardSequential || reverseSequential
    }

    private func updateValidationWarnings() {
        AssertIsOnMainThread()

        pinStrokeNormal.isHidden = validationState.isInvalid
        pinStrokeError.isHidden = !validationState.isInvalid
        validationWarningLabel.isHidden = !validationState.isInvalid
        recommendationLabel.isHidden = validationState.isInvalid

        switch validationState {
        case .tooShort:
            switch pinType {
            case .numeric:
                validationWarningLabel.text = NSLocalizedString("PIN_CREATION_NUMERIC_HINT",
                                                                comment: "Label indicating the user must use at least 4 digits")
            case .alphanumeric:
                validationWarningLabel.text = NSLocalizedString("PIN_CREATION_ALPHANUMERIC_HINT",
                                                                comment: "Label indicating the user must use at least 4 characters")
            }
        case .mismatch:
            validationWarningLabel.text = NSLocalizedString("PIN_CREATION_MISMATCH_ERROR",
                                                            comment: "Label indicating that the attempted PIN does not match the first PIN")
        case .weak:
            validationWarningLabel.text = NSLocalizedString("PIN_CREATION_WEAK_ERROR",
                                                            comment: "Label indicating that the attempted PIN is too weak")
        default:
            break
        }
    }

    private func updatePinType() {
        AssertIsOnMainThread()

        pinTextField.text = nil
        validationState = .valid

        let recommendationLabelText: String

        switch pinType {
        case .numeric:
            pinTypeToggle.setTitle(title: NSLocalizedString("PIN_CREATION_CREATE_ALPHANUMERIC",
                                                            comment: "Button asking if the user would like to create an alphanumeric PIN"))
            pinTextField.keyboardType = .asciiCapableNumberPad
            recommendationLabelText = NSLocalizedString("PIN_CREATION_NUMERIC_HINT",
                                                         comment: "Label indicating the user must use at least 4 digits")
        case .alphanumeric:
            pinTypeToggle.setTitle(title: NSLocalizedString("PIN_CREATION_CREATE_NUMERIC",
                                                            comment: "Button asking if the user would like to create an numeric PIN"))
            pinTextField.keyboardType = .default
            recommendationLabelText = NSLocalizedString("PIN_CREATION_ALPHANUMERIC_HINT",
                                                        comment: "Label indicating the user must use at least 4 characters")
        }

        pinTextField.reloadInputViews()

        if mode.isConfirming {
            pinTypeToggle.isHidden = true
            recommendationLabel.text = NSLocalizedString("PIN_CREATION_PIN_CONFIRMATION_HINT",
                                                         comment: "Label indication the user must confirm their PIN.")
        } else {
            pinTypeToggle.isHidden = false
            recommendationLabel.text = recommendationLabelText
        }
    }

    @objc func togglePinType() {
        switch pinType {
        case .numeric:
            pinType = .alphanumeric
        case .alphanumeric:
            pinType = .numeric
        }
    }

    private func enable2FAAndContinue(withPin pin: String) {
        Logger.debug("")

        pinTextField.resignFirstResponder()

        let progressView = AnimatedProgressView(
            loadingText: NSLocalizedString("PIN_CREATION_PIN_PROGRESS",
                                           comment: "Indicates the work we are doing while creating the user's pin")
        )
        view.addSubview(progressView)
        progressView.autoPinWidthToSuperview()
        progressView.autoVCenterInSuperview()

        progressView.startAnimating {
            self.view.isUserInteractionEnabled = false
            self.nextButton.alpha = 0.5
            self.pinTextField.alpha = 0
            self.validationWarningLabel.alpha = 0
            self.recommendationLabel.alpha = 0
        }

        OWS2FAManager.shared.requestEnable2FA(withPin: pin, mode: .V2).then { () -> Promise<Void> in
            if self.enableRegistrationLock {
                return OWS2FAManager.shared.enableRegistrationLockV2()
            } else {
                return Promise.value(())
            }
        }.done {
            AssertIsOnMainThread()

            // The completion handler always dismisses this view, so we don't want to animate anything.
            progressView.stopAnimatingImmediately()
            self.completionHandler(self, nil)

            // Clear the experience upgrade if it was pending.
            SDSDatabaseStorage.shared.asyncWrite { transaction in
                ExperienceUpgradeManager.clearExperienceUpgrade(.introducingPins, transaction: transaction.unwrapGrdbWrite)
            }
        }.catch { error in
            AssertIsOnMainThread()

            Logger.error("Failed to enable 2FA with error: \(error)")

            // The client may have fallen out of sync with the service.
            // Try to get back to a known good state by disabling 2FA
            // whenever enabling it fails.
            OWS2FAManager.shared.disable2FA(success: nil, failure: nil)

            progressView.stopAnimating(success: false) {
                self.nextButton.alpha = 1
                self.pinTextField.alpha = 1
                self.validationWarningLabel.alpha = 1
                self.recommendationLabel.alpha = 1
            } completion: {
                self.view.isUserInteractionEnabled = true
                progressView.removeFromSuperview()

                // If this is the first time the user is trying to create a PIN, it's a blocking flow.
                // If for some reason they hit an error, notify them that we'll try again later and
                // dismiss the flow so they aren't stuck.
                if case .creating = self.initialMode {
                    OWSActionSheets.showActionSheet(
                        title: NSLocalizedString("PIN_CREATION_ERROR_TITLE",
                                                 comment: "Error title indicating that the attempt to create a PIN failed."),
                        message: NSLocalizedString("PIN_CREATION_ERROR_MESSAGE",
                                                   comment: "Error body indicating that the attempt to create a PIN failed.")
                    ) { _ in
                        self.completionHandler(self, error)
                    }
                } else {
                    OWSActionSheets.showErrorAlert(
                        message: NSLocalizedString("ENABLE_2FA_VIEW_COULD_NOT_ENABLE_2FA",
                                                   comment: "Error indicating that attempt to enable 'two-factor auth' failed.")
                    )
                }
            }
        }
    }
}

// MARK: -

extension PinSetupViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let hasPendingChanges: Bool
        if pinType == .numeric {
            ViewControllerUtils.ows2FAPINTextField(textField, shouldChangeCharactersIn: range, replacementString: string)
            hasPendingChanges = false
        } else {
            hasPendingChanges = true
        }

        // Reset the validation state to clear errors, since the user is trying again
        validationState = .valid

        // Inform our caller whether we took care of performing the change.
        return hasPendingChanges
    }
}

extension PinSetupViewController {
    public class func disablePinWithConfirmation(fromViewController: UIViewController) -> Promise<Bool> {
        guard !OWS2FAManager.shared.isRegistrationLockV2Enabled else {
            return showRegistrationLockConfirmation(fromViewController: fromViewController)
        }

        let (promise, future) = Promise<Bool>.pending()

        let actionSheet = ActionSheetController(
            title: NSLocalizedString("PIN_CREATION_DISABLE_CONFIRMATION_TITLE",
                                     comment: "Title of the 'pin disable' action sheet."),
            message: NSLocalizedString("PIN_CREATION_DISABLE_CONFIRMATION_MESSAGE",
                                       comment: "Message of the 'pin disable' action sheet.")
        )

        let cancelAction = ActionSheetAction(title: CommonStrings.cancelButton, style: .cancel) { _ in
            future.resolve(false)
        }
        actionSheet.addAction(cancelAction)

        let disableAction = ActionSheetAction(
            title: NSLocalizedString("PIN_CREATION_DISABLE_CONFIRMATION_ACTION",
                                     comment: "Action of the 'pin disable' action sheet."),
            style: .destructive
        ) { _ in
            ModalActivityIndicatorViewController.present(
                fromViewController: fromViewController,
                canCancel: false
            ) { modal in
                SDSDatabaseStorage.shared.asyncWrite { transaction in
                    KeyBackupService.useDeviceLocalMasterKey(transaction: transaction)

                    transaction.addAsyncCompletionOnMain {
                        modal.dismiss { future.resolve(true) }
                    }
                }
            }
        }
        actionSheet.addAction(disableAction)

        fromViewController.presentActionSheet(actionSheet)

        return promise
    }

    private class func showRegistrationLockConfirmation(fromViewController: UIViewController) -> Promise<Bool> {
        let (promise, future) = Promise<Bool>.pending()

        let actionSheet = ActionSheetController(
            title: NSLocalizedString("PIN_CREATION_REGLOCK_CONFIRMATION_TITLE",
                                     comment: "Title of the 'pin disable' reglock action sheet."),
            message: NSLocalizedString("PIN_CREATION_REGLOCK_CONFIRMATION_MESSAGE",
                                       comment: "Message of the 'pin disable' reglock action sheet.")
        )

        let cancelAction = ActionSheetAction(title: CommonStrings.cancelButton, style: .cancel) { _ in
            future.resolve(false)
        }
        actionSheet.addAction(cancelAction)

        let disableAction = ActionSheetAction(
            title: NSLocalizedString("PIN_CREATION_REGLOCK_CONFIRMATION_ACTION",
                                     comment: "Action of the 'pin disable' reglock action sheet."),
            style: .destructive
        ) { _ in
            ModalActivityIndicatorViewController.present(
                fromViewController: fromViewController,
                canCancel: false
            ) { modal in
                OWS2FAManager.shared.disableRegistrationLockV2().then {
                    Guarantee { resolve in
                        modal.dismiss { resolve(()) }
                    }
                }.then { () -> Promise<Bool> in
                    disablePinWithConfirmation(fromViewController: fromViewController)
                }.done { success in
                    future.resolve(success)
                }.catch { error in
                    modal.dismiss { future.reject(error) }
                }
            }
        }
        actionSheet.addAction(disableAction)

        fromViewController.presentActionSheet(actionSheet)

        return promise
    }
}

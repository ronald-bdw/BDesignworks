//
//  VerifyScreen.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 04/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import FSHelpers_Swift
import IBDesignableKit

private extension FSScreenType {
    
    var logoHeight: CGFloat {
        switch self {
        case ._3_5  : return 180
        case ._4    : return 210
        default     : return 228 //
        }
    }
    
    var logoTopOffset: CGFloat {
        switch self {
        case ._3_5  : return 16
        default     : return UIScreen.mainScreen().bounds.size.height*Constants.defaultLogoTopConstraintRatio - topBarHeight
        }
    }
    
    var logoBottomOffset: CGFloat {
        switch self {
        case ._3_5  : return 10
        case ._4_7  : return 27
        default     : return 10 //
        }
    }
    
    var labelBottomOffset: CGFloat {
        switch self {
        case ._3_5  : return 10
        case ._4_7  : return 25
        default     : return 12 //
        }
    }
    
    var textFieldsHeight: CGFloat {
        switch self {
        case ._3_5  : return 40
        case ._4    : return 46
        case ._4_7  : return 50
        default     : return 50 //
        }
    }
    
    var mobileTexfieldVerticalOffset: CGFloat {
        switch self {
        case ._3_5  : return 10
        default     : return 10 //
        }
    }
    
    var submitButtonHeight: CGFloat {
        switch self {
        case ._3_5  : return 55
        default     : return 55 //
        }
    }
    
    var submitBottomOffset: CGFloat {
        switch self {
        case ._3_5  : return 10
        case ._4_7  : return 23
        default     : return 14 //
        }
    }
    
    var textFont: UIFont {
        switch self {
        case ._3_5  : return UIFont.systemFontOfSize(15.0)
        default     : return UIFont.systemFontOfSize(16.0) //
        }
    }
    
    var labelWidth: CGFloat {
        switch self {
        case ._3_5, ._4  : return 288
        case ._4_7       : return 279
        case ._5_5       : return 318
        }
    }
}

private struct Constants {
    static let defaultLogoTopConstraintRatio: CGFloat = 0.2 // Show how less logo's top offset relative to screen size
}

typealias VerificationMVP = MVPContainer<VerificationView, VerificationPresenter, VerificationModel>

protocol IVerificationView: class {
    func showPhoneInvalidView()
    func setLoadingState(state: LoadingState)
}

final class VerificationView: UIViewController {
    
    var scrollView: UIScrollView {
        return self.view as! UIScrollView
    }
    
    var presenter: PresenterProtocol?
    
    @IBOutlet weak var logoBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var rollButton: RollUpButton!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var areaCodeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mobileVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButton: RoundButton!
    
    @IBOutlet weak var verificationErrorView: VerificationErrorView!
    @IBOutlet weak var verificationErrorViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = VerificationMVP(controller: self)
        self.view.layoutIfNeeded()
        self.navigationController?.navigationBar.hidden = false
        self.rollButton.arrowDirection = .Right
        self.rollButton.animatable = false
        self.fs_keyboardScrollSupportRegisterForNotifications()
        self.setupUI()
    }
    
    private func setupUI() {
        guard let screenType = FSScreenType() else { return }
        self.logoBottomConstraint.constant            = screenType.logoBottomOffset
        self.logoHeightConstraint.constant            = screenType.logoHeight
        self.logoTopConstraint.constant               = screenType.logoTopOffset
        self.labelBottomConstraint.constant           = screenType.labelBottomOffset
        self.areaCodeHeightConstraint.constant        = screenType.textFieldsHeight
        self.mobileVerticalSpacingConstraint.constant = screenType.mobileTexfieldVerticalOffset
        self.submitBottomConstraint.constant          = screenType.submitBottomOffset
        self.submitHeightConstraint.constant          = screenType.submitButtonHeight
        self.mobileTextField.font                     = screenType.textFont
        self.submitButton.layer.cornerRadius          = floor(self.submitButton.fs_height/2)
        self.rollButton.chooseLabel.text              = "Area Code"
    }
    
    override func viewWillLayoutSubviews() {
        self.scrollView.contentSize = self.scrollView.bounds.size
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.mobileTextField.resignFirstResponder()
    }
    
    deinit {
        self.fs_keyboardScrollSupportRemoveNotifications()
    }
    
    @IBAction func submitPressed(sender: AnyObject){
        self.presenter?.submitTapped("7", phone: self.mobileTextField.text)
    }
}

extension VerificationView: IVerificationView {
    func showPhoneInvalidView() {
        Logger.error("phone not valid")
    }
    
    func setLoadingState(state: LoadingState) {
        switch state {
        case .Loading:
            SVProgressHUD.show()
        case .Done:
            SVProgressHUD.dismiss()
            ShowOKAlert("Success!", message: "Please, wait for sms with link to app.")
        case .Failed:
            SVProgressHUD.dismiss()
            ShowErrorAlert()
        }
    }
}

extension VerificationView: MVPView {
    typealias PresenterProtocol = IVerificationPresenter
}

extension VerificationView {
    
    func fs_keyboardScrollSupportRegisterForNotifications () {
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(self.fs_keyboardScrollSupportKeyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(self.fs_keyboardScrollSupportKeyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    func fs_keyboardScrollSupportRemoveNotifications () {
        
        let center = NSNotificationCenter.defaultCenter()
        
        center.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    var fs_keyboardScrollSupportScrollView: UIScrollView? {
        return self.scrollView
    }
    
    var fs_keyboardScrollSupportActiveField: UIView? {
        return self.mobileTextField
    }
    
    func fs_keyboardScrollSupportKeyboardWillShow (notif: NSNotification) {
        
        guard let scrollView = self.fs_keyboardScrollSupportScrollView else { return }
        
        guard let info = notif.userInfo else { return }
        guard let value = info[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = value.CGRectValue()
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardFrame.height, 0.0)
        
        scrollView.contentInset             = contentInsets
        scrollView.scrollIndicatorInsets    = contentInsets
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        guard let activeField = self.fs_keyboardScrollSupportActiveField else { return }
        
        // By default activeField must be subview of the scrollView
        guard let superview = activeField.superview else {return}
        
        var viewRect = self.view.frame
        viewRect.size.height -= keyboardFrame.height
        
        let convertedRect = superview.convertRect(activeField.frame, toView: self.view)
        
        if !CGRectContainsPoint(viewRect, convertedRect.origin)  {
            scrollView.scrollRectToVisible(activeField.frame, animated: true)
        }
    }
    
    func fs_keyboardScrollSupportKeyboardWillHide (notif: NSNotification) {
        
        guard let scrollView = self.fs_keyboardScrollSupportScrollView else { return }
        
        let contentInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}
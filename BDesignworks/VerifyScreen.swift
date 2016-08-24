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
    
    var welcomeBottomOffset: CGFloat {
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
    
    var mobileTexfieldTopOffset: CGFloat {
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
    
    var submitTopOffset: CGFloat {
        return 10
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
    
    var welcomeLabelWidth: CGFloat {
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

final class VerifyScreen: UIViewController {
    
    struct SegueIdentifiers {
        static let areaCodeSegue: String = "showAreaCodeScreen"
    }
    
    struct Constants {
        static let logoRatio             : CGFloat = 85.0/114.0
        static let submitButtonRatio     : CGFloat = 137.0/55.0
        static let errorViewHeight       : CGFloat = 60.0
        static let errorViewTopOffset    : CGFloat = 10.0
        static let errorViewBottomOffset : CGFloat = 25.0
    }
    
    var scrollView: UIScrollView {
        return self.view as! UIScrollView
    }

    @IBOutlet weak var rollButton: RollUpButton! {
        didSet {
            self.rollButton.arrowDirection = .Right
            self.rollButton.animatable = false
            self.rollButton.delegate = self
        }
    }
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var mobileTextField: UITextField! {
        didSet {
            self.mobileTextField.font = FSScreenType()?.textFont
        }
    }
    @IBOutlet weak var submitButton: RoundButton!
    @IBOutlet weak var errorView: VerificationErrorView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    private var isErrorShown: Bool = false {
        didSet {
            self.scrollView.setNeedsLayout()
            self.scrollView.layoutIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = false
        self.fs_keyboardScrollSupportRegisterForNotifications()
        self.scrollView.alwaysBounceVertical = true
        self.view.setNeedsLayout()
    }
    
    private func layoutScrollView() {
        
        guard let screenType = FSScreenType() else { return }
        let screenWidth  : CGFloat  = screenType.size.width
        
        var contentHeight: CGFloat = 0.0
        
        //Logo image frame setting
        let logoHeight: CGFloat = screenType.logoHeight
        let logoTopOffset: CGFloat = screenType.logoTopOffset
        
        self.logoImageView.frame = CGRect(x: floor((screenWidth-logoHeight*Constants.logoRatio)/2),
                                          y: logoTopOffset,
                                          width: floor(logoHeight*Constants.logoRatio),
                                          height: logoHeight)
        contentHeight += (logoTopOffset + logoHeight)
        
        //Welcome label frame setting
        let welcomeWidth: CGFloat = screenType.welcomeLabelWidth
        let welcomeTopOffset: CGFloat = screenType.logoBottomOffset
        let welcomeBottomOffset: CGFloat = screenType.welcomeBottomOffset
        let welcomeLabelHeight: CGFloat = ceil(self.welcomeLabel.textRectForBounds(welcomeLabel.bounds, limitedToNumberOfLines: 0).height)
        self.welcomeLabel.frame = CGRect(x: ceil((screenWidth-welcomeWidth)/2),
                                         y: self.logoImageView.fs_bottom + welcomeTopOffset,
                                         width: welcomeWidth,
                                         height: welcomeLabelHeight)
        
        contentHeight += (welcomeTopOffset + welcomeLabelHeight + welcomeBottomOffset)
        
        //Rollbutton & Textfield frames setting
        let height: CGFloat = screenType.textFieldsHeight
        
        //Rollbutton frame setting
        
        self.rollButton.frame = CGRect(x: self.welcomeLabel.frame.origin.x,
                                       y: self.welcomeLabel.fs_bottom + welcomeBottomOffset,
                                       width: self.welcomeLabel.frame.size.width,
                                       height: height)
        contentHeight += height
        
        //Mobile textfield frame setting
        let textFieldTopOffset: CGFloat = screenType.mobileTexfieldTopOffset
        self.mobileTextField.frame = CGRect(x: self.welcomeLabel.frame.origin.x,
                                            y: self.rollButton.fs_bottom + textFieldTopOffset,
                                            width: self.welcomeLabel.frame.size.width,
                                            height: height)
        contentHeight += (textFieldTopOffset + height)
        
        //Error view frame setting
        let errorViewTopOffset: CGFloat = Constants.errorViewTopOffset
        let errorViewBottomOffset: CGFloat = Constants.errorViewBottomOffset
        let errorViewHeight: CGFloat = self.isErrorShown ? Constants.errorViewHeight : 0
        self.errorView.frame = CGRect(x: 0,
                                      y: self.mobileTextField.fs_bottom + errorViewTopOffset,
                                      width: screenWidth,
                                      height: errorViewHeight)
        
        //Submit button frame setting
        let buttonTopOffset: CGFloat    = self.isErrorShown ? Constants.errorViewBottomOffset : screenType.submitTopOffset
        let buttonHeight: CGFloat       = screenType.submitButtonHeight
        let buttonBottomOffset: CGFloat = screenType.submitBottomOffset
        self.submitButton.frame         = CGRect(x: floor((screenWidth-buttonHeight*Constants.submitButtonRatio)/2),
                                                 y: self.isErrorShown ? self.errorView.fs_bottom + Constants.errorViewBottomOffset : self.mobileTextField.fs_bottom + buttonTopOffset,
                                                 width: floor(buttonHeight*Constants.submitButtonRatio),
                                                 height: buttonHeight)
        
        if self.isErrorShown {
            contentHeight += (errorViewTopOffset + errorViewHeight + errorViewBottomOffset)
        } else {
            contentHeight += buttonTopOffset
        }
        
        contentHeight += (buttonHeight + buttonBottomOffset)
        
        self.scrollView.contentSize = CGSize(width: screenWidth, height: ceil(contentHeight))
        self.backgroundImageView.frame = self.containerView.frame
        
        self.submitButton.layer.cornerRadius  = floor(self.submitButton.fs_height/2)
        self.rollButton.chooseLabel.text      = "Area Code"
    }
    
    override func viewWillLayoutSubviews() {
        self.layoutScrollView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.mobileTextField.resignFirstResponder()
    }
    
    //MARK: - Storyboard segues' logic
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let lIdentifier = segue.identifier else {
            super.prepareForSegue(segue, sender: sender)
            return
        }
        
        switch lIdentifier {
        case SegueIdentifiers.areaCodeSegue:
            let destinationVC: AreaCodeScreen = segue.destinationViewController as! AreaCodeScreen
            destinationVC.prepareController({[weak self] (area) in
                guard let sself = self else { return }
                sself.rollButton.chooseLabel.text = "+\(area.areaCode)"
            })
        default:
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    @IBAction func submitAction(sender: RoundButton) {
        
        self.dismissErrorView()
        
        guard self.validateFields() else {
            self.showErrorView()
            return
        }
        
        //self.performSegueWithIdentifier(<#T##identifier: String##String#>, sender: <#T##AnyObject?#>)
    }
    
    @IBAction func backPressed(sender: AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    private func validateFields() -> Bool {
        guard let text = self.mobileTextField.text where text.fs_length == 10 else { return false }
        return true
    }
    
    private func showErrorView() {
        
        UIView.animateWithDuration(0.3) {[weak self] in
            guard let sself = self else { return }
            sself.isErrorShown = true
        }
    }
    
    private func dismissErrorView() {
        
        UIView.animateWithDuration(0.3) {[weak self] in
            guard let sself = self else { return }
            sself.isErrorShown = false
        }
    }
    
    deinit {
        self.fs_keyboardScrollSupportRemoveNotifications()
    }
}

extension VerifyScreen: RollUpButtonDelegate {
    
    func rollUpButtonDidChangeState(active: Bool) {
        self.performSegueWithIdentifier(SegueIdentifiers.areaCodeSegue, sender: nil)
    }
}

extension VerifyScreen {
    
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
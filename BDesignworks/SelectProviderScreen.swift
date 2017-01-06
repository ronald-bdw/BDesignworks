//
//  SelectProvider.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 03/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

final class SelectProviderScreen: UIViewController, RollUpButtonDelegate, AutocompleteViewDelegate {
    
    struct Constants {
        static let defaultLogoTopConstraintRatio: CGFloat = 0.2 // Show how less logo's top offset relative to screen size
    }
    
    struct Segue {
        static let ShowVerify = "VerificationSegue"
        static let ShowTrialModal = "TrialSegue"
        static let ShowTrialViews = "showTrialPage"
        
        var valueForRegistrationShouldBeEqual: Bool
        
        init(valueForRegistrationShouldBeEqual: Bool) {
            self.valueForRegistrationShouldBeEqual = valueForRegistrationShouldBeEqual
        }
    }
    
    @IBOutlet weak var providerSelectionButton: RollUpButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var inactiveView: UIView!
    @IBOutlet weak var inactiveViewTapGestureRecognizer: UIGestureRecognizer!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    
    let noProviderText: String = "I do not have a provider"
    let selectProviderText: String = "Select one"
    
    fileprivate lazy var autocompleteView: AutocompleteView = {
        let autocompleteView = AutocompleteView()
        if let realm = BDRealm {
            var providers = [self.selectProviderText]
            providers.append(contentsOf: Array(realm.objects(ENProvider.self).map({$0.name})))
            providers.append(self.noProviderText)
            autocompleteView.items = providers
        }
        autocompleteView.delegate = self
        self.view.addSubview(autocompleteView)
        return autocompleteView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnalyticsManager.shared.trackScreen(named: "Select provider screen", viewController: self)
        self.logoTopConstraint.constant = self.getDefaultLogoTopOffset()
        self.providerSelectionButton.delegate = self
        self.providerSelectionButton.chooseLabel.text = self.autocompleteView.items.first
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.providersChanged), name: NSNotification.Name(rawValue: FSNotificationKey.Provider.providersChanged), object: nil)
        guard self.autocompleteView.items.count == 2 else {return}
        SVProgressHUD.show()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        self.autocompleteView.frame = CGRect(x: 0,
                                                 y: self.view.fs_height - self.autocompleteView.fs_height,
                                                 width: self.view.fs_width,
                                                 height: self.autocompleteView.fs_height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initialAnimation()
    }
    
    fileprivate func getDefaultLogoTopOffset() -> CGFloat {
        return UIScreen.main.bounds.size.height == 480 ? 50 : UIScreen.main.bounds.size.height*Constants.defaultLogoTopConstraintRatio  //Checking for iPhone 4/4s
    }
    
    fileprivate func initialAnimation() {
        self.providerSelectionButton.alpha = 0
        self.nextButton.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {[weak self] in
            guard let sself = self else { return }
            sself.providerSelectionButton.alpha = 1
            sself.nextButton.alpha = 1
        }) 
    }
    
    func providersChanged() {
        SVProgressHUD.dismiss()
        guard let realm = BDRealm else {return}
        
        var providers = [self.selectProviderText]
        providers.append(contentsOf: Array(realm.objects(ENProvider.self).map({$0.name})))
        providers.append(self.noProviderText)
        self.autocompleteView.items = providers
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let lIdentifier = segue.identifier else {
            super.prepare(for: segue, sender: sender)
            return
        }
        switch lIdentifier {
        case Segue.ShowTrialModal:
            segue.destination.transitioningDelegate = self
            segue.destination.modalPresentationStyle = .custom
            (segue.destination as? TrialPageScreen)?.delegate = self
        case Segue.ShowVerify:
            guard let segueData = sender as? Segue else {return}
            (segue.destination as? VerificationView)?.valueForRegistrationShouldBeEqual = segueData.valueForRegistrationShouldBeEqual
            if UserDefaults.standard.bool(forKey: FSUserDefaultsKey.IsProviderChosen) {
                (segue.destination as? VerificationView)?.shouldCheckForProvider = true
            } else {
                (segue.destination as? VerificationView)?.shouldCheckForProvider = false
            }
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func changeViewState(_ active: Bool) {
        self.inactiveView.isHidden = !active
    }
    
    @IBAction func disableAutocompleteViewPressed(_ sender: AnyObject) {
        self.providerSelectionButton.didChangeState(self)
    }
    
    //MARK: Actions
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        guard let labelText = self.providerSelectionButton.chooseLabel.text,
            labelText != self.selectProviderText else {return}
        
        if labelText == self.noProviderText {
            UserDefaults.standard.set(false, forKey: FSUserDefaultsKey.IsProviderChosen)
            UserDefaults.standard.synchronize()
            self.performSegue(withIdentifier: Segue.ShowTrialModal, sender: nil)
        } else {
            UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.IsProviderChosen)
            UserDefaults.standard.synchronize()
            self.performSegue(withIdentifier: Segue.ShowVerify, sender: Segue(valueForRegistrationShouldBeEqual: true))
        }
    }
    
    //MARK: Delegates
    func rollUpButtonDidChangeState(_ active: Bool) {
        if active {
            self.autocompleteView.present()
        } else {
            self.autocompleteView.dismiss()
        }
        self.changeViewState(active)
    }
    
    func autocompleteViewRowSelected(_ row: Int, item: String) {
        self.providerSelectionButton.chooseLabel.text = item
    }
    
    func donePressed() {
        self.providerSelectionButton.didChangeState(self)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
}

extension SelectProviderScreen: TrialModalViewDelegate {
    func learnMoreSelected() {
        self.performSegue(withIdentifier: Segue.ShowTrialViews, sender: nil)
    }
    
    func startTrialSelected() {
        self.performSegue(withIdentifier: Segue.ShowVerify, sender: Segue(valueForRegistrationShouldBeEqual: false))
    }
}

extension SelectProviderScreen: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController,
                                                          presenting: UIViewController?,
                                                                                   source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

//
//  ConversationScreen.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 05/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import UserNotifications

class ConversationScreen: UIViewController {
    let navigationBarImageHeight: CGFloat = 23

    @IBOutlet weak var containerView: UIView!

    var smoochController: UIViewController?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad(){
        super.viewDidLoad()
        
        AnalyticsManager.shared.trackScreen(named: "Conversation screen", viewController: self)

        UIApplication.shared.statusBarStyle = .lightContent

        self.setNavigationBarButtons()
        self.updateTitle()

        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTitle), name: FSNotification.User.userChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoaded), name: FSNotification.User.userReceived, object: nil)
        
        InAppManager.shared.delegate = self

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                // Do something here
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }else{
            let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        }

        self.containerView.isHidden = true

        self.showChat()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let controller = self.smoochController,
            let tableView = controller.view.subviews.filter({$0 is UITableView}).first,
        let headerView = tableView.subviews.filter({$0.subviews.filter({$0 is UILabel}).count == 1}).first,
            let smoochLabel = headerView.subviews.first as? UILabel else {return}
        let horizontalLabelOffset: CGFloat = 8
        let originalLabelFrame = headerView.frame
        let newLabelOrigin = CGPoint(x: originalLabelFrame.origin.x + horizontalLabelOffset, y: originalLabelFrame.origin.y)
        let newLabelSize = CGSize(width: originalLabelFrame.size.width - horizontalLabelOffset*2, height: originalLabelFrame.size.height)
        let label = UILabel(frame: CGRect(origin: newLabelOrigin, size: newLabelSize))
        label.textAlignment = .center
        label.textColor = smoochLabel.textColor
        label.font = smoochLabel.font
        label.numberOfLines = 10
        label.text = "\nWelcome to the Pair Up main page. This is where you will connect with your Pair Up coach.\n\nTap the upper right  menu to edit settings and learn more about Pair Up. Explore the About Us section to find our\nPrivacy Policy and Licensing Agreement."
        tableView.addSubview(label)
    }

    fileprivate func setNavigationBarButtons() {
        self.navigationItem.hidesBackButton = true
        let rightBarImage = Image.Icon.Menu
        let buttonWidth = navigationBarImageHeight * rightBarImage.size.width / rightBarImage.size.height
        let rightBarButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: navigationBarImageHeight))
        rightBarButton.setImage(rightBarImage, for: UIControlState())
        rightBarButton.addTarget(self.revealViewController(), action: #selector(self.revealViewController().rightRevealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.revealViewController().panGestureRecognizer().delegate = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
    }

    // commented due to logo marketing reasons
//    fileprivate func setProviderIconIfExist(user: ENUser){
//        guard user.provider != "" else {return}
//            let leftBarButtonImageView = UIImageView(image: Image.Logo.HbfLogoWhite)
//            let resizedLeftImageViewWidth = navigationBarImageHeight * leftBarButtonImageView.fs_width / leftBarButtonImageView.fs_height
//            leftBarButtonImageView.frame = CGRect(x: 0, y: 0, width: resizedLeftImageViewWidth, height: navigationBarImageHeight)
//            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonImageView)
//
//    }
    
    func userLoaded() {
        guard let user = ENUser.getMainUser() else {return}
        
        SmoochHelper.sharedInstance.startWithParameters(user)
        self.updateTitle()
        
        if SubscriptionMigrationService.shared.shouldShowSubscriptionWillExpireAlertIfNeeded {
            self.showSubscriptionWillExpireAlert(forUser: user)
        }
    }
    
    func showSubscriptionWillExpireAlert(forUser user: ENUser) {
        
        let alert = UIAlertController(title: nil, message: user.firstPopupText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
            UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.IsFirstPopupWasShown)
            UserDefaults.standard.synchronize()
            
            ShowInAppAlert()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (alertAction) in
            UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.IsFirstPopupWasShown)
            UserDefaults.standard.synchronize()
            
            alert?.dismiss(animated: true, completion: nil)
        }))
    
        self.present(alert, animated: true, completion: nil)
    }

    func showChat() {
        guard let user = ENUser.getMainUser(), user.id != 0 else {return}
        Logger.debug(user.token)
        Logger.debug(user.phoneNumber)
        Logger.debug(user.id)
        Logger.debug("Provider:\(user.provider)")
        SmoochHelper.sharedInstance.startWithParameters(user)
        
        guard let controller = Smooch.newConversationViewController() else {return}
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview((controller.view))
        self.addChildViewController(controller)
        controller.didMove(toParentViewController: self)
        self.smoochController = controller
        self.containerView.isHidden = false
        
        for view in controller.view.subviews {
            if let navbar = view as? UINavigationBar {
                navbar.isHidden = true
            }
        }
    }

    func updateTitle() {
        self.title = ENUser.getMainUser()?.fullname
    }

    @IBAction func restorePressed(_ sender: AnyObject) {
        InAppManager.shared.restoreSubscription()
    }
    
}

extension ConversationScreen: InAppManagerDelegate {
    func inAppLoadingStarted() {
        self.view.endEditing(true)
        SVProgressHUD.show()
    }

    func inAppLoadingSucceded(productType: ProductType) {
        SVProgressHUD.dismiss()
    }

    func inAppLoadingFailed(error: Swift.Error?) {
        SVProgressHUD.dismiss()
        if let error = error as? InAppErrors {
            guard error != .noSubscriptionPurchased else {return}
            ShowErrorAlert(message: error.localizedDescription)
        } else {
            ShowErrorAlert(message: error?.localizedDescription)
        }
    }
    
    func subscriptionStatusUpdated(value: Bool) {
        
    }
}

extension ConversationScreen: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.location(in: self.view).x < self.view.fs_width*4/5 {
            return false
        }
        return true
    }
}

//
//  ConversationScreen.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 05/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import UserNotifications

enum StatusCellStatus
{
    case pullToRefresh
    case noMoreHistory
    case noMessages

    var message: String {
        switch self
        {
        case .pullToRefresh:
            return "Pull to download mesage history"

        case .noMoreHistory:
            return "No more messages in history"

        case .noMessages:
            return "Your message history is empty"
        }
    }
}

class ConversationScreen: UIViewController {
    var messages = [Message]()
    let navigationBarImageHeight: CGFloat = 23

    @IBOutlet weak var containerView: UIView!

    var smoochController: UIViewController?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad(){
        super.viewDidLoad()

        self.loadMainUser()

        UIApplication.shared.statusBarStyle = .lightContent

        self.setNavigationBarButtons()
        self.updateTitle()

        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTitle), name: NSNotification.Name(rawValue: FSNotificationKey.User.userChanged), object: nil)

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
        label.text = "\nWelcome to the Pair Up main page. This is where you will connect with your Pair Up coach.\n\nTap the upper right  menu to edit settings and learn more about Pair Up. Explore the About Us section to find our Privacy Policy and Licencing Agreement."
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
    func loadMainUser() {
        let _ = Router.User.getUser.request().responseObject { (response: DataResponse<RTUserResponse>) in
            switch response.result {
            case .success(let value):
                guard let receivedUser = value.user else {return}
                self.title = receivedUser.fullname
//                self.setProviderIconIfExist(user: receivedUser)

                do {
                    let realm = try Realm()
                    try realm.write({
                        realm.add(receivedUser, update: true)
                    })
                    SmoochHelper.sharedInstance.startWithParameters(receivedUser)
                    self.updateTitle()
                }
                catch let error {
                    Logger.error(error)
                }
            case .failure(let error):
                Logger.error(error)
            }
        }
    }

    func showChat() {
        if let user = ENUser.getMainUser(),
            user.id != 0 && (InAppManager.shared.isSubscriptionAvailable || user.provider != "") {
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
    }

    func updateTitle() {
        self.title = ENUser.getMainUser()?.fullname
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    @IBAction func restorePressed(_ sender: AnyObject) {
        InAppManager.shared.restoreSubscription()
    }
}

extension ConversationScreen: InAppManagerDelegate {
    func inAppLoadingStarted() {
        SVProgressHUD.show()
    }

    func inAppLoadingSucceded(productType: ProductType) {
        SVProgressHUD.dismiss()
        self.showChat()
    }

    func inAppLoadingFailed(error: Swift.Error?) {
        SVProgressHUD.dismiss()
        guard let error = error else {return}
        ShowErrorAlert(message: error.localizedDescription)
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

//
//  ConversationScreen.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 05/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import SideMenu
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
        
        SideMenuManager.menuPresentMode = .viewSlideOut
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.menuFadeStatusBar = false
        
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
        
        
        HealthKitManager.sharedInstance.sendHealthKitData()
        
        if let user = ENUser.getMainUser(), user.id != 0 {
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
            
            for view in controller.view.subviews {
                if let navbar = view as? UINavigationBar {
                    navbar.isHidden = true
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func setNavigationBarButtons() {
        self.navigationItem.hidesBackButton = true
        let rightBarImage = Image.Icon.Menu
        let buttonWidth = navigationBarImageHeight * rightBarImage.size.width / rightBarImage.size.height
        let rightBarButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: navigationBarImageHeight))
        rightBarButton.setImage(rightBarImage, for: UIControlState())
        rightBarButton.addTarget(self, action: #selector(self.showSideMenu), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
    }
    
    fileprivate func setProviderIconIfExist(user: ENUser){
        guard user.provider != "" else {return}
            let leftBarButtonImageView = UIImageView(image: Image.Logo.HbfLogoWhite)
            let resizedLeftImageViewWidth = navigationBarImageHeight * leftBarButtonImageView.fs_width / leftBarButtonImageView.fs_height
            leftBarButtonImageView.frame = CGRect(x: 0, y: 0, width: resizedLeftImageViewWidth, height: navigationBarImageHeight)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonImageView)
        
    }
    
    func loadMainUser() {
        let _ = Router.User.getUser.request().responseObject { (response: DataResponse<RTUserResponse>) in
            switch response.result {
            case .success(let value):
                guard let receivedUser = value.user else {return}
                self.title = receivedUser.fullname
                self.setProviderIconIfExist(user: receivedUser)
                
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
    
    func updateTitle() {
        self.title = ENUser.getMainUser()?.fullname
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func showSideMenu(){
        self.performSegue(withIdentifier: "toSideMenu", sender: nil)
    }
}

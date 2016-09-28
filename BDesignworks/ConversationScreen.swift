//
//  ConversationScreen.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 05/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import SideMenu


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
        
        self.title = "Messages"
        self.setNavigationBarButtons()
        
        do {
            let realm = try Realm()
            if let user = realm.objects(ENUser.self).first , user.id != 0 {
                Logger.debug(user.token)
                Logger.debug(user.phoneNumber)
                Logger.debug(user.id)
                SmoochHelper.sharedInstance.startWithParameters("\(user.id)")
                SmoochHelper.sharedInstance.updateUserInfo(user.firstName, lastName: user.lastName, email: user.email)
                let controller = Smooch.newConversationViewController()
                controller?.view.frame = self.containerView.bounds
                self.containerView.addSubview((controller?.view)!)
                self.addChildViewController(controller!)
                controller?.didMove(toParentViewController: self)
                
                self.smoochController = controller
                
                
                for view in (controller?.view.subviews)! {
                    if let navbar = view as? UINavigationBar {
                        navbar.isHidden = true
                    }
                }
            }
        } catch let error {
            Logger.error("\(error)")
        }
        HealthKitManager.sharedInstance.sendHealthKitData()
    }
    
    fileprivate func setNavigationBarButtons() {
        self.navigationItem.hidesBackButton = true
        
        let leftBarButtonImageView = UIImageView(image: Image.Logo.HbfLogoWhite)
        let imageHeight: CGFloat = 23
        let resizedLeftImageViewWidth = imageHeight * leftBarButtonImageView.fs_width / leftBarButtonImageView.fs_height
        leftBarButtonImageView.frame = CGRect(x: 0, y: 0, width: resizedLeftImageViewWidth, height: imageHeight)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonImageView)
        
        let rightBarImage = Image.Icon.Menu
        let buttonWidth = imageHeight * rightBarImage.size.width / rightBarImage.size.height
        let rightBarButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: imageHeight))
        rightBarButton.setImage(rightBarImage, for: UIControlState())
        rightBarButton.addTarget(self, action: #selector(self.showSideMenu), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
    }
    
    func loadMainUser() {
        let _ = Router.User.getUser.request().responseObject { (response: DataResponse<RTUserResponse>) in
            switch response.result {
            case .success(let value):
                guard let receivedUser = value.user else {return}
                do {
                    let realm = try Realm()
                    try realm.write({
                        realm.add(receivedUser, update: true)
                    })
                }
                catch let error {
                    Logger.error(error)
                }
            case .failure(let error):
                Logger.error(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func showSideMenu(){
        self.performSegue(withIdentifier: "toSideMenu", sender: nil)
    }
}

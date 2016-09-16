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
    case PullToRefresh
    case NoMoreHistory
    case NoMessages
    
    var message: String {
        switch self
        {
        case .PullToRefresh:
            return "Pull to download mesage history"
            
        case .NoMoreHistory:
            return "No more messages in history"
            
        case .NoMessages:
            return "Your message history is empty"
        }
    }
}

class ConversationScreen: UIViewController {
    var messages = [Message]()
    
    @IBOutlet weak var containerView: UIView!
   
    var smoochController: UIViewController?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        SideMenuManager.menuPresentMode = .ViewSlideOut
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.menuFadeStatusBar = false
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
        self.title = "Messages"
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", style: .Plain, target: self, action: #selector(showSideMenu))
        
        do {
            let realm = try Realm()
            if let user = realm.objects(User).first where user.id != 0 {
                Logger.debug(user.token)
                Logger.debug(user.phoneNumber)
                SmoochHelper.sharedInstance.startWithParameters("\(user.id)")
                SmoochHelper.sharedInstance.updateUserInfo(user.firstName, lastName: user.lastName, email: user.email)
                let controller = Smooch.newConversationViewController()
                controller.view.frame = self.containerView.bounds
                self.containerView.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                
                self.smoochController = controller
                
                
                for view in controller.view.subviews {
                    if let navbar = view as? UINavigationBar {
                        navbar.hidden = true
                    }
                }
            }
        } catch let error {
            Logger.error("\(error)")
        }
        HealthKitManager.sharedInstance.sendHealthKitData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func showSideMenu(){
        self.performSegueWithIdentifier("toSideMenu", sender: nil)
    }
}
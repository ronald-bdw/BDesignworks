//
//  SettingsScreen.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 05/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import UserNotifications

class SettingsView: UITableViewController {
    
    let rowHeight: CGFloat = 90
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnalyticsManager.shared.trackScreen(named: "Settings screen", viewController: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateNotificationsSwitch), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        self.notificationsSwitch.addTarget(self, action: #selector(self.updateNotificationsSwitch), for: UIControlEvents.valueChanged)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateNotificationsSwitch()
        
        guard let user = ENUser.getMainUser(),
            let url = URL(string: user.avatarThumbUrl) else {return}
        self.profilePhoto.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "Profile/Avatar"))
        
    }
    
    func updateNotificationsSwitch(){
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            self.notificationsSwitch.setOn(true, animated: true)
            UIApplication.shared.registerForRemoteNotifications()
        }
        else {
            self.notificationsSwitch.setOn(false, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let lIdentifier = segue.identifier else {
            super.prepare(for: segue, sender: sender)
            return
        }
        switch lIdentifier {
        case SegueIdentifiers.Logout:
            segue.destination.transitioningDelegate = self
            segue.destination.modalPresentationStyle = .custom
            
        case SegueIdentifiers.Notifications:
            segue.destination.transitioningDelegate = self
            segue.destination.modalPresentationStyle = .custom
            
            (segue.destination as? NotificationsView)?.delegate = self
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
   
    //MARK: - Buttons action
    @IBAction func backPressed(sender: AnyObject) {
        self.moveToMainControllerTransitioned()
    }
    @IBAction func notificationSwitcherTrigered(_ sender: AnyObject) {
        self.performSegue(withIdentifier: SegueIdentifiers.Notifications, sender: self)
    }
}

extension SettingsView {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).row {
        case 3:
            return self.tableView.fs_height - (self.rowHeight * 4)
        default:
            return self.rowHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.fs_deselectSelectedRow(true)
    }
}

extension SettingsView: NotificationsViewDelegate {
    func viewWillDismiss() {
        self.updateNotificationsSwitch()
    }
}

extension SettingsView {
    enum SegueIdentifiers {
        static let Logout = "Logout"
        static let Notifications = "Notifications"
    }
}

extension SettingsView: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let screenHeight: CGFloat = presented is LogoutView ? 321 :
            presented is NotificationsView ? 400 : 0
        return ModalPresentationController(presentedViewController: presented, presenting: presenting, height: screenHeight)
    }
}

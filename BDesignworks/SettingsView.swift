//
//  SettingsScreen.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 05/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class SettingsView: UITableViewController {
    
    let rowHeight: CGFloat = 90
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notificationsSwitch.addTarget(self, action: #selector(self.notificationsSwitchStateChanged(sender:)), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateNotificationsSwitch), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
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
    
    func updateNotificationsSwitch() {
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            self.notificationsSwitch.setOn(true, animated: true)
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
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func notificationsSwitchStateChanged(sender: AnyObject) {
        let url = URL(string: UIApplicationOpenSettingsURLString)!
        UIApplication.shared.openURL(url)
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

extension SettingsView {
    enum SegueIdentifiers {
        static let Logout = "Logout"
    }
}

extension SettingsView: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting, height: 321)
    }
}

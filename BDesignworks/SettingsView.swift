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
    
    @IBOutlet var profilePhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
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

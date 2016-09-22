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
}

extension SettingsView {
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).row {
        case 3:
            return self.tableView.fs_height - (self.rowHeight * 4) - 20
        default:
            return self.rowHeight
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.fs_deselectSelectedRow(true)
        guard (indexPath as NSIndexPath).row == 4 else {return}
        
        ENUser.logout()
    }
}

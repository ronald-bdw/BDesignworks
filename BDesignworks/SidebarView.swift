//
//  SidebarTVC.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 11/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit


class SidebarCell: UITableViewCell
{
    let sideView = UIView()
    var cellSelected = false {
        didSet {
            self.backgroundColor = cellSelected ? AppColors.MainColor : UIColor.clearColor()
            self.sideView.hidden = cellSelected ? false : true
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.selectionStyle = .None
        
        self.sideView.hidden = true
        self.sideView.backgroundColor = AppColors.GoldColor
        self.sideView.frame = CGRectMake(0, 0, 10, self.frame.height)
        self.contentView.addSubview(self.sideView)
    }
}

typealias SidebarMVP = MVPContainer<SidebarView,SidebarPresenter,SidebarModel>

protocol ISidebarView: class {
    func updateView(user: User)
}

class SidebarView: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    let rowHeight = CGFloat(60)
    let profileRowHeight = CGFloat(150)
    var lastSelected = 0
    
    var presenter: PresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = SidebarMVP(controller: self)
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "running"))
        self.presenter?.viewLoaded()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row
        {
        case 0:
            return profileRowHeight
        case 1, 2, 4:
            return rowHeight
        default:
            return self.tableView.frame.size.height - (self.rowHeight * 3) - profileRowHeight - 20
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 3 {
            return
        }
        
        var cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: self.lastSelected, inSection: 0)) as! SidebarCell
        cell.cellSelected = false
        
        self.lastSelected = indexPath.row
        
        cell = self.tableView.cellForRowAtIndexPath(indexPath) as! SidebarCell
        cell.cellSelected = true
    }
}

extension SidebarView: ISidebarView {
    func updateView(user: User) {
        self.nameLabel.text = user.fullname
        self.emailLabel.text = user.email
    }
}

extension SidebarView: MVPView {
    typealias PresenterProtocol = ISidebarPresenterView
}

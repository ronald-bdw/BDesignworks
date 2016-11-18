//
//  SidebarTVC.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 11/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit


class SidebarCell: UITableViewCell {
    let sideView = UIView()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.backgroundColor = super.isSelected ? UIColor(fs_hexString: "1D3B57") : UIColor.clear
        self.sideView.isHidden = super.isSelected ? false : true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        self.sideView.isHidden = true
        self.sideView.backgroundColor = AppColors.GoldColor
        self.sideView.frame = CGRect(x: 0, y: 0, width: 10, height: self.frame.height)
        self.contentView.addSubview(self.sideView)
    }
}

typealias SidebarMVP = MVPContainer<SidebarView,SidebarPresenter,SidebarModel>

protocol ISidebarView: class {
    func updateView(_ user: ENUser)
}

class SidebarView: UITableViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet var leadingTableViewCellsConstraints: [NSLayoutConstraint]!
    
    let rowHeight = CGFloat(90)
    let profileRowHeight = CGFloat(164)
    
    var leftViewOffset = CGFloat(-260)
    
    var presenter: PresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = SidebarMVP(controller: self)
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "right-menu-bg"))
        self.presenter?.viewLoaded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.leadingTableViewCellsConstraints.forEach({$0.constant = self.view.fs_width + self.leftViewOffset})
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).row
        {
        case 0:
            return profileRowHeight
        case 1, 2, 4:
            return rowHeight
        default:
            return self.tableView.frame.size.height - (self.rowHeight * 3) - profileRowHeight - 20
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 2 else {return}
        self.shareButtonClicked()
    }
    
    func shareButtonClicked() {
        let textToShare = "Check out PearUp for your smartphone. Download it today from https://itunes.apple.com/us/app/pearup/id1164491229"
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = {[weak self] (activityType, success, objects, error) in
            self?.tableView.fs_deselectSelectedRow(true)
        }
        self.present(activityVC, animated: true, completion: nil)
    }
}

extension SidebarView: ISidebarView {
    func updateView(_ user: ENUser) {
        self.nameLabel.text = user.fullname
        self.emailLabel.text = user.email
        
        guard let url = URL(string: user.avatarThumbUrl) else {return}
        self.avatarImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "Profile/Avatar"))
    }
}

extension SidebarView: MVPView {
    typealias PresenterProtocol = ISidebarPresenterView
}

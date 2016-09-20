//
//  PushScreen.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 05/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit


class PushScreen: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: CheckboxTableView!
    @IBOutlet weak var tableViewHeightContraint: NSLayoutConstraint!
    
    let settings = ["Activity of any kind", "Notification request from any coach", "Nothing (Push notifications off)"]
    var checked: Int?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.register(PushSettingCell.self, forCellReuseIdentifier: "PushSettingCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.layer.cornerRadius = 14
        self.tableView.layer.borderColor = AppColors.MainColor?.cgColor
        self.tableView.layer.borderWidth = 1
    }
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.settings.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "PushSettingCell", for: indexPath) as! PushSettingCell
        
        if let checkedRow = checked , (indexPath as NSIndexPath).row == checkedRow {
            cell.checked = true
        }
        
        cell.label.text = settings[(indexPath as NSIndexPath).row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.checked = (indexPath as NSIndexPath).row
        self.tableView.reloadData()
    }
}


class PushSettingCell: UITableViewCell
{
    var checked = false {
        didSet {
            self.checkImage.image = checked ? UIImage(named: "Check") : nil
        }
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
}

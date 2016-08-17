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
        
        self.tableView.registerClass(PushSettingCell.self, forCellReuseIdentifier: "PushSettingCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.layer.cornerRadius = 14
        self.tableView.layer.borderColor = AppColors.MainColor?.CGColor
        self.tableView.layer.borderWidth = 1
    }
    
    //MARK: TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.settings.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 80
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("PushSettingCell", forIndexPath: indexPath) as! PushSettingCell
        
        if let checkedRow = checked where indexPath.row == checkedRow {
            cell.checked = true
        }
        
        cell.label.text = settings[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.checked = indexPath.row
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

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

class StatusCell: UITableViewCell
{
    @IBOutlet var statusMessageLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    func configure(status: StatusCellStatus, date: NSDate)
    {
        self.backgroundColor = UIColor.clearColor()
        
        self.statusMessageLabel.text = status.message
        
        if status == .PullToRefresh {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            self.dateLabel.text = dateFormatter.stringFromDate(date)
        }
    }
}

class IncomingMessageCell: UITableViewCell
{
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var messageLabel: UILabel!
    
    func configure(message: Message)
    {
        self.backgroundColor = UIColor.clearColor()
        
        self.messageLabel.text = message.text
    }
}

class OutcomingMessageCell: UITableViewCell
{
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var messageLabel: UILabel!
    
    func configure(message: Message)
    {
        self.backgroundColor = UIColor.clearColor()
        
        self.messageLabel.text = message.text
    }
}


class ConversationScreen: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var messages = [Message]()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        SideMenuManager.menuPresentMode = .ViewSlideOut
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.menuFadeStatusBar = false
        
        self.title = "Chat with Syrio Forel"
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", style: .Plain, target: self, action: #selector(showSideMenu))
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.textField.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func reloadTableView()
    {
        self.tableView.reloadData()
        self.scrollToBottom()
    }
    
    func showSideMenu()
    {
        self.performSegueWithIdentifier("toSideMenu", sender: nil)
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject)
    {
        guard let text = self.textField.text where text != "" else {
            return
        }
        
        self.messages.append(Message(text: self.textField.text!, date: NSDate(), isIncoming: false))
        self.textField.text = ""
        self.reloadTableView()
    }
    
    func scrollToBottom()
    {
        guard self.messages.count > 0 else { return }
        
        let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
        self.tableView.layoutIfNeeded()
    }
    
    
    //MARK: TableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return (indexPath.row == 0) ? 65 : 40
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.messages.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if indexPath.row == 0 {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("StatusCell") as! StatusCell
            
            let status = (self.messages.count > 0) ? StatusCellStatus.PullToRefresh : StatusCellStatus.NoMessages
            cell.configure(status, date: NSDate())
            
            return cell
        }
        
        
        let message = self.messages[indexPath.row-1]
        
        if message.isIncoming {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("IncomingMessage") as! IncomingMessageCell
            cell.configure(message)
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("OutcomingMessage") as! OutcomingMessageCell
            cell.configure(message)
            return cell
        }
    }
}

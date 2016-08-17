//
//  AutocompleteController.swift
//  Link-generator
//
//  Created by Eduard Lisin on 14/07/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

protocol AutocompleteViewDelegate
{
    func autocompleteViewRowSelected(row: Int, item: String)
}

class AutocompleteView: UIView, UITableViewDelegate, UITableViewDataSource
{
    var items = [String]() {
        didSet {
            self.layoutSubviews()
        }
    }
    var delegate:AutocompleteViewDelegate? = nil
    
    private let cellHeigh = CGFloat(50)
    private let tableView = UITableView()
    
    
    
    //MARK: Lifecycle
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        xibSetup()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        xibSetup()
    }
    
    func present()
    {
        UIView.animateWithDuration(0.2) {
            self.alpha = 1
        }
    }
    
    func dismiss()
    {
        UIView.animateWithDuration(0.2) {
            self.alpha = 0
        }
    }
    
    func xibSetup()
    {
        self.alpha = 0
        
        self.layer.cornerRadius = 20
        
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = .None
        self.addSubview(self.tableView)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let tableHeightToFit = self.cellHeigh * CGFloat(self.items.count)
        
        if self.frame.height >= tableHeightToFit {
            var newFrame = self.frame
            newFrame.origin.y = newFrame.origin.y + (self.frame.height - tableHeightToFit)
            newFrame.size.height = tableHeightToFit
            self.frame = newFrame
        }
        
        self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        self.tableView.reloadData()
    }
    
    //MARK: TableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return cellHeigh
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = self.items[indexPath.row]
        cell.textLabel?.textAlignment = .Center
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.delegate?.autocompleteViewRowSelected(indexPath.row, item: self.items[indexPath.row])
        self.dismiss()
    }
}
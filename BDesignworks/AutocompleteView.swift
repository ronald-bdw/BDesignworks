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
            self.selectedItem = self.items.first ?? nil
            self.layoutSubviews()
        }
    }
    
    var selectedItem: String!
    
    var availableItems: [String] {
        return self.items.filter { $0 != self.selectedItem }
    }
    
    var delegate: AutocompleteViewDelegate? = nil
    
    private let cellHeight = CGFloat(50)
    private let tableView = UITableView()
    
    private lazy var shapeLayer: CAShapeLayer = CAShapeLayer()
    
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
        
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = .None
        
        let bezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: CGSize(width: 10, height: 10))
        self.shapeLayer.path = bezierPath.CGPath
        self.shapeLayer.borderWidth = 1
        self.shapeLayer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.mask = self.shapeLayer
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true
        
        self.addSubview(self.tableView)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let tableHeightToFit = self.cellHeight * CGFloat(self.availableItems.count)
        self.shapeLayer.frame = self.bounds
        self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: CGSize(width: 10, height: 10)).CGPath
        var newFrame = self.frame
        newFrame.origin.y = newFrame.origin.y + (self.frame.height - tableHeightToFit)
        newFrame.size.height = tableHeightToFit
        self.frame = newFrame

        self.tableView.frame = self.bounds
        self.tableView.reloadData()
    }
    
    //MARK: TableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return self.cellHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.availableItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = self.availableItems[indexPath.row]
        cell.textLabel?.textAlignment = .Center
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.selectedItem = self.availableItems[indexPath.row]
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.delegate?.autocompleteViewRowSelected(indexPath.row, item: self.selectedItem)
        self.dismiss()
    }
}
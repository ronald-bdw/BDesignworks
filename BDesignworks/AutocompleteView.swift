//
//  AutocompleteController.swift
//  Link-generator
//
//  Created by Eduard Lisin on 14/07/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

protocol AutocompleteViewDelegate: class {
    func autocompleteViewRowSelected(row: Int, item: String)
}

final class AutocompleteView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    struct Constants {
        static let defaultCellHeight         : CGFloat = 50
        static let defaultAnimationDuration  : NSTimeInterval = 0.2
        static let cellIdentifier            : String = "Cell"
        static let defaultCornerRadius       : CGSize = CGSize(width: 10, height: 10)
    }
    
    override class func layerClass() -> AnyClass { return CAShapeLayer.self }
    
    var items: [ProviderOption] = [] {
        didSet {
            self.selectedItem = self.items.first ?? nil
            self.layoutSubviews()
        }
    }
    
    private var selectedItem: ProviderOption!  {
        didSet {
            self.availableItems = self.items.filter { $0 != self.selectedItem }
            self.tableView.reloadData()
        }
    }
    
    private var availableItems: [ProviderOption] = []
    
    weak var delegate: AutocompleteViewDelegate?
    
    private let tableView = UITableView()
    
    private var shapeLayer: CAShapeLayer {
        return self.layer as! CAShapeLayer
    }
    
    //MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.xibSetup()
    }
    
    func present() {
        UIView.animateWithDuration(Constants.defaultAnimationDuration) { [weak self] in
            guard let sself = self else { return }
            sself.hidden = false
        }
    }
    
    func dismiss() {
        UIView.animateWithDuration(Constants.defaultAnimationDuration) { [weak self] in
            guard let sself = self else { return }
            sself.hidden = true
        }
    }
    
    private func xibSetup() {
        
        self.hidden = true
        
        //UITableView's setup
        self.tableView.backgroundColor    = UIColor.whiteColor()
        self.tableView.separatorStyle     = .None
        self.tableView.layer.cornerRadius = Constants.defaultCornerRadius.height
        self.tableView.scrollEnabled      = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        self.addSubview(self.tableView)
        
        //CAShapeLayer's setup
        self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: Constants.defaultCornerRadius).CGPath
        self.shapeLayer.backgroundColor = UIColor.clearColor().CGColor
        self.shapeLayer.strokeColor     = UIColor.lightGrayColor().CGColor
        self.shapeLayer.fillColor       = UIColor.whiteColor().CGColor
        self.shapeLayer.lineWidth       = 1
        self.shapeLayer.borderColor     = UIColor.lightGrayColor().CGColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.fs_height = CGFloat(self.availableItems.count) * Constants.defaultCellHeight
        self.tableView.frame = CGRectInset(self.bounds, 1, 1)
        self.shapeLayer.frame = self.bounds
        self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds,
                                            byRoundingCorners: [.BottomLeft, .BottomRight],
                                            cornerRadii: Constants.defaultCornerRadius).CGPath
    }
    
    //MARK: TableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.defaultCellHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availableItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(Constants.cellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = self.availableItems[indexPath.row].rawValue
        cell.textLabel?.textAlignment = .Center
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.delegate?.autocompleteViewRowSelected(indexPath.row, item: self.availableItems[indexPath.row].rawValue)
        self.dismiss()
        self.selectedItem = self.availableItems[indexPath.row]
    }
}
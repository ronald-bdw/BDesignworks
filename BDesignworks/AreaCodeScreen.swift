//
//  AreaCodeScreen.swift
//  BDesignworks
//
//  Created by Aynur Galiev on 22.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import FSHelpers_Swift

final class AreaCodeScreen: UIViewController {
    
    struct Constants {
        static let cellIdentifier: String = "AreaCodeCell"
        static let headerIdentifier: String = "HeaderView"
    }
    
    private var sectionTitles: [String] = []
    private var resultBlock: ((area: Area?) -> Void)?
    
    func prepareController(resultBlock: ((area: Area?) -> Void)?) {
        self.resultBlock = resultBlock
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sectionTitles = countryCodes.map { $0.0 }.sort()
        self.tableView.sectionIndexColor = UIColor(fs_hexString: "274273")
        self.tableView.registerNib(UINib(nibName: HeaderView.className, bundle: nil), forHeaderFooterViewReuseIdentifier: Constants.headerIdentifier)
    }
}

extension AreaCodeScreen: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key: String = self.sectionTitles[section]
        return countryCodes[key]?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: AreaCodeCell = tableView.dequeueReusableCellWithIdentifier(Constants.cellIdentifier) as! AreaCodeCell
        let key: String = self.sectionTitles[indexPath.section]
        if let area: Area = countryCodes[key]?.fs_objectAtIndexOrNil(indexPath.row) {
            cell.prepareCell(area)
        }
        return cell
    }
}

extension AreaCodeScreen: UITableViewDelegate {
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: HeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(Constants.headerIdentifier) as! HeaderView
        headerView.titleLabel.text = self.sectionTitles[section]
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 36.0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitles[section]
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.sectionTitles
    }
}
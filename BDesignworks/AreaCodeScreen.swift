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
    
    struct CellIdentifier {
        static let cellIdentifier   : String = "AreaCodeCell"
        static let headerIdentifier : String = "HeaderView"
    }
    
    struct Constants {
        static let defualtCellHeight   : CGFloat = 36.0
        static let defaultHeaderHeight : CGFloat = 36.0
    }
    
    fileprivate var sectionTitles: [String] = []
    fileprivate var resultBlock: ((_ area: Area) -> Void)?
    
    func prepareController(_ resultBlock: ((_ area: Area) -> Void)?) {
        self.resultBlock = resultBlock
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accessibilityLabel = "Area code screen"
        self.sectionTitles = countryCodes.map { $0.0 }.sorted()
        self.tableView.sectionIndexColor = UIColor(fs_hexString: "29537C")
        self.tableView.register(UINib(nibName: HeaderView.className, bundle: nil), forHeaderFooterViewReuseIdentifier: CellIdentifier.headerIdentifier)
    }
}

extension AreaCodeScreen: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key: String = self.sectionTitles[section]
        return countryCodes[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AreaCodeCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.cellIdentifier) as! AreaCodeCell
        let key: String = self.sectionTitles[(indexPath as NSIndexPath).section]
        if let area: Area = countryCodes[key]?.fs_objectAtIndexOrNil(indexPath.row) {
            cell.prepareCell(area)
        }
        return cell
    }
}

extension AreaCodeScreen: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: HeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellIdentifier.headerIdentifier) as! HeaderView
        headerView.titleLabel.text = self.sectionTitles[section]
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.defualtCellHeight
    }
    
    private func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.defaultHeaderHeight
    }
    
    @objc(sectionIndexTitlesForTableView:) func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sectionTitles
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key: String = self.sectionTitles[(indexPath as NSIndexPath).section]
        guard let area = countryCodes[key]?.fs_objectAtIndexOrNil(indexPath.row) else { return }
        self.resultBlock?(area)
        FSDispatch_after_short(0.2) {[weak self] in
            let _ = self?.navigationController?.popViewController(animated: true)
        }
    }
}

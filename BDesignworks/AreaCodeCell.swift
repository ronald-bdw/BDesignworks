//
//  AreaCodeCell.swift
//  BDesignworks
//
//  Created by Aynur Galiev on 22.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

struct Area {
    let countryName: String
    let areaCode: Int
    
    init(countryName: String, areaCode: Int) {
        self.countryName = countryName
        self.areaCode = areaCode
    }
}

final class AreaCodeCell: UITableViewCell {

    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var areaCodeLabel: UILabel!
    
//    override var selected: Bool {
//        didSet {
//            
//        }
//    }
    
    func prepareCell(area: Area) {
        self.countryNameLabel.text = area.countryName
        self.areaCodeLabel.text = "\(area.areaCode)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.countryNameLabel.text = nil
        self.areaCodeLabel.text = nil
    }
}

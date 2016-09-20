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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = UIColor(fs_hexString: "29537C")
    }
    
    fileprivate func updateCell() {
        if self.isSelected {
            self.countryNameLabel.textColor = UIColor.white
            self.areaCodeLabel.textColor    = UIColor.white
        } else {
            self.countryNameLabel.textColor = UIColor(fs_hexString: "555555")
            self.areaCodeLabel.textColor    = UIColor(fs_hexString: "555555")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.updateCell()
    }
    
    func prepareCell(_ area: Area) {
        self.countryNameLabel.text = area.countryName
        self.areaCodeLabel.text = "\(area.areaCode)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.countryNameLabel.text = nil
        self.areaCodeLabel.text = nil
    }
}

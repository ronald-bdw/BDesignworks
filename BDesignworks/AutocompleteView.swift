//
//  AutocompleteController.swift
//  Link-generator
//
//  Created by Eduard Lisin on 14/07/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

protocol AutocompleteViewDelegate: class {
    func autocompleteViewRowSelected(_ row: Int, item: String)
    func donePressed()
}

final class AutocompleteView: UIView {
    
    struct Constants {
        static let defaultCellHeight         : CGFloat = 60
        static let pickerViewHeight          : CGFloat = Constants.defaultCellHeight * 3 + Constants.doneViewHeight
        static let doneViewHeight            : CGFloat = 40
        static let doneButtonHeight          : CGFloat = 20
        static let doneButtonWidth           : CGFloat = 60
        static let defaultAnimationDuration  : TimeInterval = 0.2
        static let pickerTextLeftOffset      : CGFloat = 32
    }
    
    override class var layerClass : AnyClass { return CAShapeLayer.self }
    
    var items: [ProviderOption] = [] {
        didSet {
            self.layoutSubviews()
        }
    }
    
    weak var delegate: AutocompleteViewDelegate?
    
    fileprivate let pickerView = UIPickerView()
    private let doneView = UIView()
    private let doneButton = UIButton()
    
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
        UIView.animate(withDuration: Constants.defaultAnimationDuration, animations: { [weak self] in
            guard let sself = self else { return }
            sself.isHidden = false
        }) 
    }
    
    func dismiss() {
        UIView.animate(withDuration: Constants.defaultAnimationDuration, animations: { [weak self] in
            guard let sself = self else { return }
            sself.isHidden = true
        }) 
    }
    
    fileprivate func xibSetup() {
        
        self.isHidden = true
        
        self.doneView.frame = CGRect(x: 0, y: 0, width: self.fs_width, height: Constants.doneViewHeight)
        self.doneView.backgroundColor = FSRGBA(250, 250, 250, 0.98)
        
        self.doneButton.setTitle("Done", for: .normal)
        self.doneButton.setTitleColor(FSRGBA(41, 83, 124, 1), for: .normal)
        self.doneButton.addTarget(self, action: #selector(self.donePressed), for: .touchUpInside)
        self.doneView.addSubview(doneButton)
        self.addSubview(self.doneView)
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.backgroundColor = FSRGBA(250, 250, 250, 0.98)
        self.pickerView.fs_borderColor = FSRGBA(200, 200, 200, 1)
        self.pickerView.fs_borderWidth = 1
        self.pickerView.frame = CGRect(x: 0, y: Constants.doneViewHeight, width: self.fs_width, height: Constants.pickerViewHeight - Constants.doneViewHeight)
        
        self.addSubview(self.pickerView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.fs_height = Constants.pickerViewHeight
        self.doneView.frame = CGRect(x: 0, y: 0, width: self.fs_width, height: Constants.doneViewHeight)
        self.pickerView.frame = CGRect(x: 0, y: Constants.doneViewHeight, width: self.fs_width, height:  Constants.pickerViewHeight - Constants.doneViewHeight)
        
        let doneButtonX = self.fs_width - Constants.doneButtonWidth - 10
        let doneButtonY = (self.doneView.fs_height - Constants.doneButtonHeight)/2
        
        self.doneButton.frame = CGRect(x: doneButtonX, y: doneButtonY, width: Constants.doneButtonWidth, height: Constants.doneButtonHeight)
        self.pickerView.reloadAllComponents()
    }
    
    func donePressed() {
        self.delegate?.donePressed()
    }
}

extension AutocompleteView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.items.count
    }
}

extension AutocompleteView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: Constants.pickerTextLeftOffset, y: 0, width: self.fs_width - Constants.pickerTextLeftOffset, height: Constants.defaultCellHeight))
        label.font = Fonts.OpenSans.bold.getFontOfSize(18)
        label.textColor = pickerView.selectedRow(inComponent: component) == row ? FSRGBA(41, 83, 124, 1) : UIColor.lightGray
        label.text = self.items[row].rawValue
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return Constants.defaultCellHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadAllComponents()
        self.delegate?.autocompleteViewRowSelected(row, item: self.items[row].rawValue)
    }
}

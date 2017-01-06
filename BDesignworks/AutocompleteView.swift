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
        static let doneViewHeight            : CGFloat = 50
        static let doneButtonHeight          : CGFloat = 20
        static let doneButtonWidth           : CGFloat = 60
        static let defaultAnimationDuration  : TimeInterval = 0.2
        static let pickerTextLeftOffset      : CGFloat = 32
    }
    
    override class var layerClass : AnyClass { return CAShapeLayer.self }
    
    var items: [String] = [] {
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
        if self.pickerView.selectedRow(inComponent: 0) == 0, self.items.count > 1 {
            self.pickerView.selectRow(1, inComponent: 0, animated: false)
            self.delegate?.autocompleteViewRowSelected(1, item: self.items[1])
            self.pickerView.reloadComponent(0)
        }
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
        
        self.doneView.backgroundColor = UIColor(fs_hexString: "2E527C")
        
        let doneButtonTitle = NSAttributedString(string: "Done", attributes: [NSFontAttributeName: Fonts.OpenSans.regular.getFontOfSize(18), NSForegroundColorAttributeName: UIColor.white])
        self.doneButton.setAttributedTitle(doneButtonTitle, for: .normal)
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
        self.doneButton.frame = self.doneView.frame
        self.pickerView.frame = CGRect(x: 0, y: Constants.doneViewHeight, width: self.fs_width, height:  Constants.pickerViewHeight - Constants.doneViewHeight)
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
        label.text = self.items[row]
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return Constants.defaultCellHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadAllComponents()
        self.delegate?.autocompleteViewRowSelected(row, item: self.items[row])
    }
}

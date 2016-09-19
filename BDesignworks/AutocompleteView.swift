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

final class AutocompleteView: UIView {
    
    struct Constants {
        static let defaultCellHeight         : CGFloat = 60
        static let pickerViewHeight          : CGFloat = Constants.defaultCellHeight * 3
        static let defaultAnimationDuration  : NSTimeInterval = 0.2
        static let pickerTextLeftOffset      : CGFloat = 32
    }
    
    override class func layerClass() -> AnyClass { return CAShapeLayer.self }
    
    var items: [ProviderOption] = [] {
        didSet {
            self.layoutSubviews()
        }
    }
    
    weak var delegate: AutocompleteViewDelegate?
    
    private let pickerView = UIPickerView()
    
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
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.backgroundColor = FSRGBA(250, 250, 250, 0.98)
        self.pickerView.fs_borderColor = FSRGBA(200, 200, 200, 1)
        self.pickerView.fs_borderWidth = 1
        self.pickerView.frame = CGRect(x: 0, y: 0, width: self.fs_width, height: Constants.pickerViewHeight)
        self.addSubview(self.pickerView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.fs_height = Constants.pickerViewHeight
        self.pickerView.frame = CGRect(x: 0, y: 0, width: self.fs_width, height:  Constants.pickerViewHeight)
        self.pickerView.reloadAllComponents()
    }
}

extension AutocompleteView: UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.items.count
    }
}

extension AutocompleteView: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: Constants.pickerTextLeftOffset, y: 0, width: self.fs_width - Constants.pickerTextLeftOffset, height: Constants.defaultCellHeight))
        label.font = Fonts.OpenSans.Bold.getFontOfSize(18)
        label.textColor = pickerView.selectedRowInComponent(component) == row ? FSRGBA(41, 83, 124, 1) : UIColor.lightGrayColor()
        label.text = self.items[row].rawValue
        return label
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return Constants.defaultCellHeight
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadAllComponents()
        self.delegate?.autocompleteViewRowSelected(row, item: self.items[row].rawValue)
    }
}
//
//  BaseView.swift
//  BDesignworks
//
//  Created by Galiev Aynur on 20.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import FSHelpers_Swift

//Inherit from that class if you want add .XIB-view in storyboard
class BaseView: UIView {
    
    fileprivate var view: UIView?
    
    //MARK: - Manual initializing
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    //MARK: - Storyboard initializing
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    fileprivate func initialize() {
        self.backgroundColor = UIColor.clear
        self.loadViewFromNib()
        guard let lView = self.view else { return }
        lView.backgroundColor = UIColor.clear
        lView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(lView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.view?.frame = self.bounds
        self.view?.bounds = self.bounds
    }
    
    fileprivate func loadViewFromNib() {
        let bundle : Bundle = Bundle(for: self.classForCoder)
        let nib    : UINib    = UINib(nibName: self.className, bundle: bundle)
        self.view = nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}

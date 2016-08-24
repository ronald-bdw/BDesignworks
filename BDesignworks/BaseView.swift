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
    
    private var view: UIView?
    
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
    
    private func initialize() {
        self.backgroundColor = UIColor.clearColor()
        self.loadViewFromNib()
        guard let lView = self.view else { return }
        lView.backgroundColor = UIColor.clearColor()
        lView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(lView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.view?.frame = self.bounds
    }
    
    private func loadViewFromNib() {
        let bundle: NSBundle = NSBundle(forClass: self.classForCoder)
        let nib = UINib(nibName: self.className, bundle: bundle)
        self.view = nib.instantiateWithOwner(self, options: nil).first as? UIView
    }
}

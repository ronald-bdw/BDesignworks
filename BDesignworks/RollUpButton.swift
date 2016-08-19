//
//  RollUpButton.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 03/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

protocol RollUpButtonDelegate {
    func rollUpButtonDidChangeState(active: Bool)
}

class RollUpButton: UIView {
    
    private let inset = CGFloat(12)
    private lazy var triangle: UIImageView = {
       let imageView = UIImageView()
       imageView.image = UIImage(named: "TriangleTop")
       imageView.contentMode = UIViewContentMode.ScaleAspectFit
       return imageView
    }()
    let label = UILabel()
    var active = false {
        didSet {
            self.triangle.transform = (active == true) ?  CGAffineTransformMakeRotation(CGFloat(M_PI)) :  CGAffineTransformMakeRotation(CGFloat(0))
            self.changeBoundingPath()
        }
    }
    
    private lazy var shapeLayer: CAShapeLayer = CAShapeLayer()
    
    var delegate: RollUpButtonDelegate?
    
    //MARK: Lifecycle
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        self.setup()
    }
    
    private func changeBoundingPath() {
        if self.active {
            self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: CGSize(width: 10, height: 10)).CGPath
        } else {
            self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .AllCorners, cornerRadii: CGSize(width: 10, height: 10)).CGPath
        }
    }
    
    
    func setup()
    {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipTriangle)))
        
        self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: 10, height: 10)).CGPath
        self.shapeLayer.backgroundColor = UIColor.clearColor().CGColor
        self.layer.masksToBounds = true
        self.layer.mask = self.shapeLayer
        
        self.backgroundColor = UIColor.whiteColor()
        //self.layer.cornerRadius = 10
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        self.addSubview(self.triangle)
        
        self.label.text = "Tap to chose"
        self.label.textColor = UIColor.darkGrayColor()
        self.addSubview(self.label)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.triangle.frame = CGRectMake(self.frame.size.width - self.inset - 15, (self.frame.size.height - 15)/2, 15, 15)
        self.label.frame = CGRectMake(self.inset, 0, self.frame.size.width - self.inset * 4, self.frame.size.height)
    }
    
    func flipTriangle()
    {
        self.active = !self.active
        self.delegate?.rollUpButtonDidChangeState(self.active)
        
    }
}

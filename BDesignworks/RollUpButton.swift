//
//  RollUpButton.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 03/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit


protocol RollUpButtonDelegate
{
    func rollUpButtonDidChangeState(active: Bool)
}


class RollUpButton: UIView
{
    private let inset = CGFloat(12)
    private let triangle = UIImageView(image: UIImage(named: "TriangleTop"))
    let label = UILabel()
    var active = false {
        didSet {
            self.triangle.transform = (active == true) ?  CGAffineTransformMakeRotation(CGFloat(M_PI)) :  CGAffineTransformMakeRotation(CGFloat(0))
        }
    }
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
    
    func setup()
    {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipTriangle)))
        
        self.backgroundColor = UIColor.whiteColor()
        self.layer.cornerRadius = 10
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

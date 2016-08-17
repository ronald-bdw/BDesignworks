//
//  ToggleButton.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 04/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit


protocol ToggleButtonDelegate
{
    func toggleButtonWasPressed(on: Bool, buttonTag: Int)
}


class ToggleButton: UIView
{
    var delegate: ToggleButtonDelegate?
    var toggleTag = 0
    private(set) var on = false
    var color = UIColor.grayColor() {
        didSet {
            self.circle.layer.borderColor = self.color.CGColor
            self.dot.backgroundColor = self.color
        }
    }
    
    
    private let circle = UIView()
    private let dot = UIView()
    private var isAnimating = false
    
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
        self.backgroundColor = UIColor.whiteColor()
        self.userInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pressed)))
        
        self.circle.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)
        self.circle.layer.cornerRadius = self.frame.size.width/2;
        self.circle.layer.borderWidth = self.frame.size.width / 30 * 2;
        self.circle.layer.borderColor = self.color.CGColor
        self.addSubview(self.circle)
        
        let dotSize = self.frame.size.width - self.frame.size.width/4;
        self.dot.frame = CGRectMake((self.frame.size.width - dotSize)/2, (self.frame.size.height - dotSize)/2, dotSize, dotSize)
        self.dot.backgroundColor = self.color
        self.dot.layer.cornerRadius = dotSize/2;
        self.dot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
        self.addSubview(self.dot);
    }
    
    func pressed()
    {
        if !self.isAnimating
        {
            self.on = !self.on
            self.isAnimating = true
            self.delegate?.toggleButtonWasPressed(self.on, buttonTag: self.toggleTag)
            
            dispatch_async(dispatch_get_main_queue(),{
                UIView.animateWithDuration(0.1, animations: {
                    self.dot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
                }) { (finished) in
                    UIView.animateWithDuration(0.1, animations: {
                        self.dot.transform = self.on ? CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0) : CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001)
                    }) {(finished) in
                        self.isAnimating = false
                    }
                }
            })
        }
    }
    
    func setToggled(on: Bool)
    {
        self.on = on
        
        dispatch_async(dispatch_get_main_queue(),{
            UIView.animateWithDuration(0.1) {
                self.dot.transform = self.on ? CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0) : CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001)
            }
        })
    }
}

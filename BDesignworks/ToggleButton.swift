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
    func toggleButtonWasPressed(_ on: Bool, buttonTag: Int)
}


class ToggleButton: UIView
{
    var delegate: ToggleButtonDelegate?
    var toggleTag = 0
    fileprivate(set) var on = false
    var color = UIColor.gray {
        didSet {
            self.circle.layer.borderColor = self.color.cgColor
            self.dot.backgroundColor = self.color
        }
    }
    
    
    fileprivate let circle = UIView()
    fileprivate let dot = UIView()
    fileprivate var isAnimating = false
    
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
        self.backgroundColor = UIColor.white
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pressed)))
        
        self.circle.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.width)
        self.circle.layer.cornerRadius = self.frame.size.width/2;
        self.circle.layer.borderWidth = self.frame.size.width / 30 * 2;
        self.circle.layer.borderColor = self.color.cgColor
        self.addSubview(self.circle)
        
        let dotSize = self.frame.size.width - self.frame.size.width/4;
        self.dot.frame = CGRect(x: (self.frame.size.width - dotSize)/2, y: (self.frame.size.height - dotSize)/2, width: dotSize, height: dotSize)
        self.dot.backgroundColor = self.color
        self.dot.layer.cornerRadius = dotSize/2;
        self.dot.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001);
        self.addSubview(self.dot);
    }
    
    func pressed()
    {
        if !self.isAnimating
        {
            self.on = !self.on
            self.isAnimating = true
            self.delegate?.toggleButtonWasPressed(self.on, buttonTag: self.toggleTag)
            
            DispatchQueue.main.async(execute: {
                UIView.animate(withDuration: 0.1, animations: {
                    self.dot.transform = CGAffineTransform.identity.scaledBy(x: 1.2, y: 1.2);
                }, completion: { (finished) in
                    UIView.animate(withDuration: 0.1, animations: {
                        self.dot.transform = self.on ? CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0) : CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
                    }, completion: {(finished) in
                        self.isAnimating = false
                    }) 
                }) 
            })
        }
    }
    
    func setToggled(_ on: Bool)
    {
        self.on = on
        
        DispatchQueue.main.async(execute: {
            UIView.animate(withDuration: 0.1, animations: {
                self.dot.transform = self.on ? CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0) : CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
            }) 
        })
    }
}

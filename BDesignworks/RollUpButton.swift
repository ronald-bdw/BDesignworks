//
//  RollUpButton.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 03/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

protocol RollUpButtonDelegate: class {
    func rollUpButtonDidChangeState(_ active: Bool)
}

enum ArrowDirection: String {
    case Right  = "Right"
    case Bottom = "Bottom"
    
    var image: UIImage! {
        return UIImage(named: "Arrow/\(self.rawValue)")
    }
}

final class RollUpButton: BaseView {
    
    struct Constants {
        static let defaultCornerRadius: CGSize = CGSize(width: 10, height: 10)
        static let labelLeadingOffset : CGFloat = 15
        static let arrowWidth         : CGFloat = 15
        static let arrowTrailingOffset: CGFloat = 12
    }
    
    override class var layerClass : AnyClass { return CAShapeLayer.self }
    
    //MARK: - UI Outlets
    @IBOutlet weak var triangleImageView: UIImageView!
    @IBOutlet weak var chooseLabel: UILabel!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    
    var active: Bool = false {
        didSet { self.update() }
    }
    
    var animatable: Bool = true
    
    fileprivate var shapeLayer: CAShapeLayer {
        return self.layer as! CAShapeLayer
    }
    
    var arrowDirection: ArrowDirection = .Bottom {
        didSet {
            self.triangleImageView.image = self.arrowDirection.image
        }
    }
    
    weak var delegate: RollUpButtonDelegate?
    
    //MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    fileprivate func update() {
        
        guard self.animatable else { return }
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let sself = self else { return }
            //Updating arrow
            let angle: CGFloat = sself.active == true ? CGFloat(M_PI) : 0
            sself.triangleImageView.transform = CGAffineTransform(rotationAngle: angle)
            
            //Updating bounding path
            sself.updateBoundingPath()
        }) 
    }
    
    
    fileprivate func setup() {
        self.triangleImageView.image = self.arrowDirection.image
        self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds,
                                            byRoundingCorners: UIRectCorner.allCorners,
                                            cornerRadii: Constants.defaultCornerRadius).cgPath
        self.shapeLayer.backgroundColor = UIColor.clear.cgColor
        self.shapeLayer.strokeColor = UIColor.lightGray.cgColor
        self.shapeLayer.fillColor = UIColor.white.cgColor
        self.shapeLayer.lineWidth = 1
        self.clipsToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.chooseLabel.frame = CGRect(x: Constants.labelLeadingOffset,
                                        y: 0,
                                        width: self.fs_width - Constants.labelLeadingOffset - Constants.arrowTrailingOffset - Constants.arrowWidth,
                                        height: self.fs_height)
        self.triangleImageView.frame = CGRect(x: self.chooseLabel.fs_trailing,
                                              y: 0,
                                              width: Constants.arrowWidth,
                                              height: self.fs_height)
        self.updateBoundingPath()
    }
    
    fileprivate func updateBoundingPath() {
        
//        if self.active {
//            guard self.animatable else { return }
//            self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds,
//                                                 byRoundingCorners: [.TopLeft, .TopRight],
//                                                 cornerRadii: Constants.defaultCornerRadius).CGPath
//        } else {
            self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds,
                                                byRoundingCorners: .allCorners,
                                                cornerRadii: Constants.defaultCornerRadius).cgPath
//        }
    }
    
    @IBAction func didChangeState(_ sender: AnyObject) {
        self.active = !self.active
        self.delegate?.rollUpButtonDidChangeState(self.active)
    }
}

//
//  RollUpButton.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 03/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

protocol RollUpButtonDelegate: class {
    func rollUpButtonDidChangeState(active: Bool)
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
    }
    
    override class func layerClass() -> AnyClass { return CAShapeLayer.self }
    
    //MARK: - UI Outlets
    @IBOutlet weak var triangleImageView: UIImageView!
    @IBOutlet weak var chooseLabel: UILabel!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    
    var active: Bool = false {
        didSet { self.update() }
    }
    
    var animatable: Bool = true
    
    private var shapeLayer: CAShapeLayer {
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
    
    private func update() {
        
        guard self.animatable else { return }
        
        UIView.animateWithDuration(0.2) { [weak self] in
            guard let sself = self else { return }
            //Updating arrow
            let angle: CGFloat = sself.active == true ? CGFloat(M_PI) : 0
            sself.triangleImageView.transform = CGAffineTransformMakeRotation(angle)
            
            //Updating bounding path
            sself.updateBoundingPath()
        }
    }
    
    
    private func setup() {
        self.triangleImageView.image = self.arrowDirection.image
        self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds,
                                            byRoundingCorners: UIRectCorner.AllCorners,
                                            cornerRadii: Constants.defaultCornerRadius).CGPath
        self.shapeLayer.backgroundColor = UIColor.clearColor().CGColor
        self.shapeLayer.strokeColor = UIColor.lightGrayColor().CGColor
        self.shapeLayer.fillColor = UIColor.whiteColor().CGColor
        self.shapeLayer.lineWidth = 1
        self.clipsToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateBoundingPath()
    }
    
    private func updateBoundingPath() {
        
        if self.active {
            guard self.animatable else { return }
            self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds,
                                                 byRoundingCorners: [.TopLeft, .TopRight],
                                                 cornerRadii: Constants.defaultCornerRadius).CGPath
        } else {
            self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds,
                                                byRoundingCorners: .AllCorners,
                                                cornerRadii: Constants.defaultCornerRadius).CGPath
        }
    }
    
    @IBAction func didChangeState(sender: AnyObject) {
        self.active = !self.active
        self.delegate?.rollUpButtonDidChangeState(self.active)
    }
}

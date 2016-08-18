//
//  ModalPresentationController.swift
//  BDesignworks
//
//  Created by Aynur Galiev on 18.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

final class ModalPresentationController: UIPresentationController {
    
    private var duration: NSTimeInterval = 0.25
    
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        return view
    }()
    
    private var widthRatio  : CGFloat = 0.84
    private var heightRatio : CGFloat = 0.39
    private var presentedControllerRadius: CGFloat = 8
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        guard let lContainerView = self.containerView else { return CGRectZero }
        return CGRect(x     : lContainerView.fs_width*0.5*(1-widthRatio),
                      y     : lContainerView.fs_height*0.5*(1-heightRatio),
                      width : lContainerView.fs_width*widthRatio,
                      height: lContainerView.fs_height*heightRatio)
    }
    
    override func containerViewWillLayoutSubviews() {
        let frame = self.frameOfPresentedViewInContainerView()
        self.presentedView()?.frame = frame
        self.presentedView()?.layer.cornerRadius = self.presentedControllerRadius
    }
    
    override func presentationTransitionWillBegin() {
        
        guard let lContainerView = self.containerView else { return }
        self.dimmingView.frame = lContainerView.frame
        self.dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backgroundDidTapped(_:))))
        self.containerView?.addSubview(self.dimmingView)
        
        guard let lPresentedView = self.presentedView() else { return }
        
        lPresentedView.frame = CGRectOffset(self.frameOfPresentedViewInContainerView(), 0, -heightRatio*lContainerView.fs_height)
        lContainerView.addSubview(lPresentedView)
        
        let coordinator = self.presentedViewController.transitionCoordinator()
        coordinator?.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext) in
            self.dimmingView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            lPresentedView.frame = self.frameOfPresentedViewInContainerView()
        }, completion: { (context: UIViewControllerTransitionCoordinatorContext) in
                
        })
    }
    
    func backgroundDidTapped(sender: UIView) {
        self.presentedViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        
        guard let lPresentedView = self.presentedView() else { return }
        guard let lContainerView = self.containerView else { return }
        
        let coordinator = self.presentedViewController.transitionCoordinator()
        coordinator?.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext) in
            self.dimmingView.backgroundColor = UIColor.clearColor()
            lPresentedView.frame = CGRectOffset(self.frameOfPresentedViewInContainerView(), 0, -self.heightRatio*lContainerView.fs_height)
            
            }, completion: { (context: UIViewControllerTransitionCoordinatorContext) in
                self.dimmingView.removeFromSuperview()
        })
    }
}

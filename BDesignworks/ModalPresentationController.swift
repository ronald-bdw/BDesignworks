//
//  ModalPresentationController.swift
//  BDesignworks
//
//  Created by Aynur Galiev on 18.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import FSHelpers_Swift

final class ModalPresentationController: UIPresentationController {
    
    fileprivate var duration: TimeInterval = 0.25
    
    fileprivate lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    fileprivate var modalScreenWidth  : CGFloat = 315 // Width of modal UIViewController
    fileprivate var modalScreenHeight : CGFloat = 258 // Height of modal UIViewController
    
    fileprivate var presentedControllerRadius: CGFloat = 8
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, height: CGFloat = 258) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.modalScreenHeight = height
    }
    
    override var frameOfPresentedViewInContainerView : CGRect {
        guard let lContainerView = self.containerView else { return CGRect.zero }
        return CGRect(x     : (lContainerView.fs_width-modalScreenWidth)*0.5,
                      y     : (lContainerView.fs_height-modalScreenHeight)*0.5,
                      width : modalScreenWidth,
                      height: modalScreenHeight)
    }
    
    override func containerViewWillLayoutSubviews() {
        let frame = self.frameOfPresentedViewInContainerView
        self.presentedView?.frame = frame
        self.presentedView?.layer.cornerRadius = self.presentedControllerRadius
    }
    
    override func presentationTransitionWillBegin() {
        
        guard let lContainerView = self.containerView else { return }
        self.dimmingView.frame = lContainerView.frame
        self.dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backgroundDidTapped(_:))))
        lContainerView.addSubview(self.dimmingView)
        
        guard let lPresentedView = self.presentedView else { return }
        
        lPresentedView.frame = self.frameOfPresentedViewInContainerView.offsetBy(dx: 0, dy: lContainerView.fs_height - (lContainerView.fs_height-lPresentedView.fs_height)/2)
        lContainerView.addSubview(lPresentedView)
        
        let coordinator = self.presentedViewController.transitionCoordinator
        coordinator?.animate(alongsideTransition: {[weak self] (context: UIViewControllerTransitionCoordinatorContext) in
            guard let sself = self else { return }
            sself.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            lPresentedView.frame = sself.frameOfPresentedViewInContainerView
        }, completion: nil)
    }
    
    func backgroundDidTapped(_ sender: UIView) {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        
        guard let lPresentedView = self.presentedView else { FSDLog("Presented view can't be nil"); return }
        guard let lContainerView = self.containerView   else { FSDLog("Container view can't be nil"); return }
        
        let coordinator = self.presentedViewController.transitionCoordinator
        coordinator?.animate(alongsideTransition: {[weak self] (context: UIViewControllerTransitionCoordinatorContext) in
            guard let sself = self else { return }
            sself.dimmingView.backgroundColor = UIColor.clear
            sself.presentedView?.backgroundColor = UIColor.clear
            lPresentedView.frame = sself.frameOfPresentedViewInContainerView.offsetBy(dx: 0,
                                                dy: -lContainerView.fs_height + (lContainerView.fs_height-lPresentedView.fs_height)/2)
        }, completion: {[weak self] (context: UIViewControllerTransitionCoordinatorContext) in
            guard let sself = self else { return }
            sself.dimmingView.removeFromSuperview()
        })
    }
}

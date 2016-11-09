//
//  NotifcationView.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 10/10/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class NotificationView: BaseView {
    
    @IBOutlet weak var textLabel: UILabel!
    
    static func presentOnTop(with title: String) {
        guard let window = UIApplication.shared.windows.first else {return}
        let view = NotificationView(frame: CGRect(x: 8, y: 20, width: window.fs_width - 16, height: 60))
        view.textLabel.text = title
        view.alpha = 0
        window.addSubview(view)
        window.bringSubview(toFront: view)
        view.subviews.first?.translatesAutoresizingMaskIntoConstraints = true
        
        let gestureRecogniser = UITapGestureRecognizer()
        gestureRecogniser.addTarget(view, action: #selector(view.tapped))
        view.addGestureRecognizer(gestureRecogniser)
        UIView.animate(withDuration: 0.3) {
            view.alpha = 1
        }
        FSDispatch_after_short(2.0) {
            view.removeFromSuperviewAnimated()
        }
    }
    
    private func removeFromSuperviewAnimated() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            }, completion: { (success) in
                self.removeFromSuperview()
        })
    }
    
    func tapped() {
        var presentedController = UIApplication.shared.windows.first?.rootViewController
        
        var nextController = presentedController?.presentedViewController
//        while !(nextController is UISideMenuNavigationController) && nextController != nil  {
//            presentedController = nextController
//            nextController = presentedController?.presentedViewController
//        }
        presentedController?.presentedViewController?.dismiss(animated: true, completion: nil)
        
        self.removeFromSuperviewAnimated()
    }
}

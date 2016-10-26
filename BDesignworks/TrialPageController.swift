//
//  TrialPageController.swift
//  BDesignworks
//
//  Created by Ildar Zalyalov on 26.10.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class TrialPageController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet var selectionViews: [TrialPageSelectionView]!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        for view in destinationViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
                return
            }
        }
    }
    
    @IBAction func startTrialAction(_ sender: AnyObject) {
        //ShowRegistrationViewController()
    }

}

extension TrialPageController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / self.containerView.fs_width)
        
        self.selectionViews.forEach({$0.selected = false})
        self.selectionViews[page].selected = true
    }
}

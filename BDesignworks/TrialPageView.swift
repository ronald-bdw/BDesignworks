//
//  TrialPageView.swift
//  BDesignworks
//
//  Created by Ellina Kuznecova on 02.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class TrialPageView: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var selectionViews: [TrialPageSelectionView]!
    
    func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destination
        for view in destinationViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
                return
            }
        }
    }
    
    @IBAction func backPressed(_ sender: AnyObject) {
        ShowInitialViewController()
    }
    
    @IBAction func startTrialAction(_ sender: AnyObject) {
        ShowRegistrationViewController()
    }
    
}

extension TrialPageView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / self.containerView.fs_width)
        
        self.selectionViews.forEach({$0.selected = false})
        self.selectionViews[page].selected = true
    }
}

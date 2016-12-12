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
    weak var scrollView: UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnalyticsManager.shared.trackScreen(named: "Trial Screens", viewController: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        for view in destinationViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
                return
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let scrollView = self.scrollView else {return}
        let offsetPoint = CGPoint(x: 0, y: scrollView.contentOffset.y)
        self.scrollView?.setContentOffset(offsetPoint, animated: false)
    }

}

extension TrialPageController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollView = scrollView
        
        let page = Int(scrollView.contentOffset.x / self.containerView.fs_width)
        
        self.selectionViews.forEach({$0.selected = false})
        self.selectionViews[page].selected = true
    }
}

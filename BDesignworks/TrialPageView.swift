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
    @IBOutlet weak var firstViewSelectionView: TrialPageSelectionView!
    @IBOutlet weak var secondViewSelectionView: TrialPageSelectionView!
    @IBOutlet weak var thirdViewSelectionView: TrialPageSelectionView!
    @IBOutlet weak var fourthViewSelectionView: TrialPageSelectionView!
    
    private var selectionViews: [TrialPageSelectionView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectionViews = [self.firstViewSelectionView, self.secondViewSelectionView, self.thirdViewSelectionView, self.fourthViewSelectionView]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController
        for view in destinationViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
                return
            }
        }
    }
    
    @IBAction func backPressed(sender: AnyObject) {
        ShowInitialViewController()
    }
    
    @IBAction func startTrialAction(sender: AnyObject) {
        ShowRegistrationViewController()
    }
    
}

extension TrialPageView: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / self.containerView.fs_width)
        
        self.selectionViews.forEach({$0.selected = false})
        self.selectionViews[page].selected = true
    }
}
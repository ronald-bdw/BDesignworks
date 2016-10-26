//
//  TrialPageContainer.swift
//  BDesignworks
//
//  Created by Ildar Zalyalov on 26.10.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class TrialPageContainer: UIViewController {

    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //if current device is iPhone5 and lower
        guard self.view.bounds.height < CGFloat(570) else {return}
        for view in self.containerView.subviews{
            for containsView in view.subviews{
                for innerView in containsView.subviews{
                    if let label = innerView as? UILabel{
                        label.font = label.font.withSize(label.font.pointSize - 4)
                    }
                }
            }
            
        }
    }

}

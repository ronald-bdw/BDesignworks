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

        // Do any additional setup after loading the view.
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

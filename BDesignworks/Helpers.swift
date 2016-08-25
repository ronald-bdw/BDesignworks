//
//  Helpers.swift
//  BDesignworks
//
//  Created by Kruperfone on 19.11.15.
//  Copyright © 2015 Flatstack. All rights reserved.
//

import Foundation

enum LoadingState {
    case Loading
    case Done
    case Failed
}

let topBarHeight: CGFloat = 64.0 // Status and navigation bar's summary height

//MARK: - Foundation
extension NSObject {
    
    class var className: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    var className: String {
        return self.dynamicType.className
    }
}

enum FSScreenType {
    
    case _3_5
    case _4
    case _4_7
    case _5_5
    
    init?() {
        switch UIScreen.mainScreen().bounds.size {
        case CGSize(width: 320, height: 480): self = _3_5
        case CGSize(width: 320, height: 568): self = _4
        case CGSize(width: 375, height: 667): self = _4_7
        case CGSize(width: 414, height: 736): self = _5_5
        default                             : return nil
        }
    }
}

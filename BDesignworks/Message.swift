//
//  Message.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 06/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class Message
{
    var text = ""
    var date = NSDate()
    var isIncoming = false
    
    init() {}
    
    convenience init(text: String, date: NSDate, isIncoming: Bool)
    {
        self.init()
        
        self.text = text
        self.date = date
        self.isIncoming = isIncoming
    }
}
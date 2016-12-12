//
//  AnalyticsManager.swift
//  BDesignworks
//
//  Created by Ellina Kuznecova on 12.12.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

enum LoginWrongFlowType {
    case noProvider
    case notRegistered
    case alreadyRegistered
    
    var description: String {
        switch self {
        case .noProvider: return "User has no provider"
        case .notRegistered: return "User not registered"
        case .alreadyRegistered: return "User already registered"
        }
    }
}

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.detectMessageSending), name: NSNotification.Name.SKTMessageUploadCompleted, object: nil)
    }
    
    @objc func detectMessageSending() {
        let messageSentDate = Date()
        guard let messages = Smooch.conversation()?.messages, messages.count > 1 else {return}
        guard let preLastMessage = (messages[messages.endIndex - 2] as? SKTMessage),
            preLastMessage.isFromCurrentUser == false,
            let coachMessageDate = preLastMessage.date else {return}
        Heap.track("Message sent", withProperties: ["Response time": Int(messageSentDate.timeIntervalSince(coachMessageDate)/60)])
    }
    
    func detectWrongFlow(type: LoginWrongFlowType) {
        Heap.track("Wrong flow", withProperties: ["Wrong flow type": type.description])
    }
}

//
//  Extensions.swift
//  BDesignworks
//
//  Created by Kruperfone on 19.11.15.
//  Copyright © 2015 Flatstack. All rights reserved.
//

import Foundation

extension UIAlertController {
    func presentOnModal() {
        guard   let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let window = appDelegate.window else {return}
        var presentedController = window.rootViewController
        var nextController = presentedController?.presentedViewController
        while nextController != nil  {
            presentedController = nextController
            nextController = presentedController?.presentedViewController
        }
        presentedController?.present(self, animated: true, completion: nil)
    }
    
    /** Presents alert only if no alert presented on view.
     */
    func presentIfNoAlertsPresented() {
        guard   let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let window = appDelegate.window else {return}
        var presentedController = window.rootViewController
        var nextController = presentedController?.presentedViewController
        while nextController != nil  {
            presentedController = nextController
            nextController = presentedController?.presentedViewController
        }
        if let _ = presentedController as? UIAlertController {return}
        presentedController?.present(self, animated: true, completion: nil)
    }
}

extension UIViewController {
    func getLastController() -> UIViewController? {
        var presentedController: UIViewController? = self
        var nextController = presentedController?.presentedViewController
        while nextController != nil  {
            presentedController = nextController
            nextController = presentedController?.presentedViewController
        }
        return presentedController
    }
    
    func moveToMainControllerTransitioned() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let window = appDelegate.window
            else {return}
        let desiredViewController = Storyboard.main.storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
        
        let view1 = self.view!
        let view2 = desiredViewController.view!
        
        view2.frame = window.bounds
        window.addSubview(view2)
        
        let transition = CATransition()
        transition.startProgress = 0
        transition.endProgress = 1
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        transition.duration = 0.2
        
        view1.layer.add(transition, forKey: "transition")
        view2.layer.add(transition, forKey: "transition")
        
        FSDispatch_after_short(0.2) {
            window.rootViewController = desiredViewController
        }
    }
}

public extension Sequence {
    
    func categorise<U : Hashable>(_ keyFunc: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var dict: [U:[Iterator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}

extension Dictionary where Value: Equatable {
    
    public mutating func updateIfNotDefault(_ object: Value?, forKey key: Key, defaultValue: Value) {
        guard defaultValue != object else {return}
        self.fs_updateIfExist(object, forKey: key)
    }
}

extension Date {
    public func dateByAddingHours (_ hours: Int) -> Date {
        let timeInterval:TimeInterval = self.timeIntervalSinceReferenceDate + FSTimePeriod.hour.rawValue * TimeInterval(hours)
        let newDate = Date(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    public func dateByAddingMinutes (_ minutes: Int) -> Date {
        let timeInterval:TimeInterval = self.timeIntervalSinceReferenceDate + FSTimePeriod.minute.rawValue * TimeInterval(minutes)
        let newDate = Date(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    public func dateByAddingTime(_ time: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        
        let dateComponents = (calendar as NSCalendar).components([.year, .month, .day], from: self)
        
        let timeComponents = (calendar as NSCalendar).components([.hour, .minute, .second], from: time)
        
        var dateTimeComponents = DateComponents()
        dateTimeComponents.year = dateComponents.year
        dateTimeComponents.month = dateComponents.month
        dateTimeComponents.day = dateComponents.day
        dateTimeComponents.hour = timeComponents.hour
        dateTimeComponents.minute = timeComponents.minute
        dateTimeComponents.second = timeComponents.second
        
        return calendar.date(from: dateTimeComponents)!
    }
    
    func compareByDay(_ date: Date) -> ComparisonResult {
        
        let currentTimeIntervalSince1970 = self.fs_midnightDate().timeIntervalSince1970
        let comparisionTimeIntervalSince1970 = date.fs_midnightDate().timeIntervalSince1970
        
        if currentTimeIntervalSince1970 < comparisionTimeIntervalSince1970 {
            return .orderedAscending
        }
        if currentTimeIntervalSince1970 > comparisionTimeIntervalSince1970 {
            return .orderedDescending
        }
        return .orderedSame
    }
    
    static func datesByDay(from startDate: Date, to finishDate: Date) -> [Date] {
        var result: [Date] = []
        var appendDate = startDate
        while appendDate.compareByDay(finishDate) == .orderedAscending || appendDate.compareByDay(finishDate) == .orderedSame {
            result.append(appendDate)
            appendDate = appendDate.fs_dateByAddingDays(1)
        }
        return result
    }
    
    static func getDateFromISO8601(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.date(from: dateString)
    }
}

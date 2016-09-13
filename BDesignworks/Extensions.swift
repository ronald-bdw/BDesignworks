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
        guard   let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
            let window = appDelegate.window else {return}
        var presentedController = window.rootViewController
        var nextController = presentedController?.presentedViewController
        while nextController != nil  {
            presentedController = nextController
            nextController = presentedController?.presentedViewController
        }
        presentedController?.presentViewController(self, animated: true, completion: nil)
    }
    
    /** Presents alert only if no alert presented on view.
     */
    func presentIfNoAlertsPresented() {
        guard   let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
            let window = appDelegate.window else {return}
        var presentedController = window.rootViewController
        var nextController = presentedController?.presentedViewController
        while nextController != nil  {
            presentedController = nextController
            nextController = presentedController?.presentedViewController
        }
        if let _ = presentedController as? UIAlertController {return}
        presentedController?.presentViewController(self, animated: true, completion: nil)
    }
}

public extension SequenceType {
    
    func categorise<U : Hashable>(@noescape keyFunc: Generator.Element -> U) -> [U:[Generator.Element]] {
        var dict: [U:[Generator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}

public extension Dictionary {
    
    public mutating func updateIfNotDefault(object: Value?, forKey key: Key, defaultValue: Value) {
        guard let updateObject = object as? AnyObject?, let defaultValuet = defaultValue as? AnyObject else {return}
        guard defaultValuet.isEqual(updateObject) == false else {return}
        self.fs_updateIfExist(object, forKey: key)
    }
}

extension NSDate {
    public func dateByAddingHours (hours: Int) -> NSDate {
        let timeInterval:NSTimeInterval = self.timeIntervalSinceReferenceDate + FSTimePeriod.Hour.rawValue * NSTimeInterval(hours)
        let newDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    public func dateByAddingMinutes (minutes: Int) -> NSDate {
        let timeInterval:NSTimeInterval = self.timeIntervalSinceReferenceDate + FSTimePeriod.Minute.rawValue * NSTimeInterval(minutes)
        let newDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    public func dateByAddingTime(time: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone(abbreviation: "UTC")!
        
        let dateComponents = calendar.components([.Year, .Month, .Day], fromDate: self)
        
        let timeComponents = calendar.components([.Hour, .Minute, .Second], fromDate: time)
        
        let dateTimeComponents = NSDateComponents()
        dateTimeComponents.year = dateComponents.year
        dateTimeComponents.month = dateComponents.month
        dateTimeComponents.day = dateComponents.day
        dateTimeComponents.hour = timeComponents.hour
        dateTimeComponents.minute = timeComponents.minute
        dateTimeComponents.second = timeComponents.second
        
        return calendar.dateFromComponents(dateTimeComponents)!
    }
    
    func compareByDay(date: NSDate) -> NSComparisonResult {
        
        let currentTimeIntervalSince1970 = self.fs_midnightDate().timeIntervalSince1970
        let comparisionTimeIntervalSince1970 = date.fs_midnightDate().timeIntervalSince1970
        
        if currentTimeIntervalSince1970 < comparisionTimeIntervalSince1970 {
            return .OrderedAscending
        }
        if currentTimeIntervalSince1970 > comparisionTimeIntervalSince1970 {
            return .OrderedDescending
        }
        return .OrderedSame
    }
    
    static func datesByDay(from startDate: NSDate, to finishDate: NSDate) -> [NSDate] {
        var result: [NSDate] = []
        var appendDate = startDate
        while appendDate.compareByDay(finishDate) == .OrderedAscending || appendDate.compareByDay(finishDate) == .OrderedSame {
            result.append(appendDate)
            appendDate = appendDate.fs_dateByAddingDays(1)
        }
        return result
    }
    
    static func getDateFromISO8601(dateString: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        return dateFormatter.dateFromString(dateString)
    }
}

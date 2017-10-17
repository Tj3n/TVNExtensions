//
//  NSDateExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 3/17/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation

enum DateType: String {
    case OneWeek = "oneWeek", OneMonth = "oneMonth", ThreeMonths = "threeMonths", SixMonths = "sixMonths", None = ""
}

extension Date {
    
    // init with timestamp in Int
    init(timeStamp: Int) {
        self.init(timeIntervalSince1970: Double(timeStamp))
    }
    
    //Convert NSDate to timestamp in Int
    func toTimeStamp() -> Int {
        return Int(self.timeIntervalSince1970)
    }
    
    //Not safe to use
//    convenience init?(string: String, format: String) {
//        
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = format
//        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
//        let date = dateFormatter.dateFromString(string)
//        
//        if let date = date {
//            self.init(timeInterval: 0, sinceDate: date)
//        } else {
//            self.init()
//        }
//    }
    
    
    init(day: Int, month: Int, year: Int) {
        var comps = DateComponents()
        comps.day = day
        comps.month = month
        comps.year = year
        
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "GMT")!
        
        self.init(timeInterval: 0, since: cal.date(from: comps)!)
    }
    
    var year: Int {
        get {
            let calendar = Calendar.current
            return (calendar as NSCalendar).component(.year, from: self)
        }
    }
    
    var month: Int {
        get {
            let calendar = Calendar.current
            return (calendar as NSCalendar).component(.month, from: self)
        }
    }
    
    var day: Int {
        get {
            let calendar = Calendar.current
            return (calendar as NSCalendar).component(.day, from: self)
        }
    }
    
    static func dateAtMidnight() -> Date {
        let today = Date()
        var todayString = today.dateToString("MM dd yyyy")
        todayString.append(" 23:59:59")
        return Date.dateFromString(todayString, format: "MM dd yyyy HH:mm:ss")!
    }
    
    static func dateFromString(_ string: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        return dateFormatter.date(from: string)
    }
    
    //Convert NSDate to String
    func dateToString(_ format: String?) -> String {
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = NSLocale.systemLocale()
        
        if format != nil && format!.characters.count > 0 {
            dateFormatter.dateFormat = format
        } else {
            dateFormatter.dateFormat = "yyyy MM dd"
        }
        
        if let _ = self as Date! {
            let strDate = dateFormatter.string(from: self)
            return strDate
        } else {
            return dateFormatter.string(from: Date())
        }
    }
    
    // 1 day before this date
    func dateByMinusOneDay() -> Date {
        return dateByMinusNumberOfDay(1)
    }
    
    // 30 day before this date
    func dateByMinusOneMonth() -> Date {
        return dateByMinusNumberOfDay(30)
    }
    
    // 7 day before this date
    func dateByMinusOneWeek() -> Date {
        return dateByMinusNumberOfDay(7)
    }
    
    // 3 month before this date divide with 7 day * 4 week * 3 month
    func dateByMinusThreeMonth() -> Date {
        return dateByMinusNumberOfDay(7*4*3)
    }
    
    // 6 month before this date divide with 30 day * 6 month
    func dateByMinusSixMonth() -> Date {
        return dateByMinusNumberOfDay(30*6)
    }
    
    // date with dateType enum
    func dateByDateType(_ dateType: DateType) -> Date? {
        switch dateType {
        case .OneWeek:
            return self.dateByMinusOneWeek()
        case .OneMonth:
            return self.dateByMinusOneMonth()
        case .ThreeMonths:
            return self.dateByMinusThreeMonth()
        case .SixMonths:
            return self.dateByMinusSixMonth()
        case .None:
            return nil
        }
    }
    
    // Date before this date a period of days
    func dateByMinusNumberOfDay(_ day: Int) -> Date {
        var dayComp = DateComponents()
        dayComp.day = -day
        
        let date = (Calendar.current as NSCalendar).date(byAdding: dayComp, to: self, options: [])
        
        return date!
    }
    
    static func numberOfDayInYear(fromDate date: Date) -> Int {
        let oneYearFromCurrent = Date(day: date.day, month: date.month, year: date.year-1)
        
        return Date.numberOfDayInPeriod(fromDate: date, toDate: oneYearFromCurrent)
    }
    
    static func numberOfDayInPeriod(fromDate date: Date, toDate: Date) -> Int {
        
        let numberOfDaysInYear = (Calendar.current as NSCalendar).components(.day, from: date, to: toDate, options: [])
        
        if numberOfDaysInYear.day! < 0 {
            return numberOfDaysInYear.day! * -1
        }
        
        return numberOfDaysInYear.day!
    }
}

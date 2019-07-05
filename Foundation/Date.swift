//
//  NSDateExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 3/17/16.
//  Copyright © 2016 Tien Nhat Vu. All rights reserved.
//

import Foundation

public extension DateFormatter {
    /// Careful with date format change, should only be use to work with loop or collectionView,... to prevent recreated of DateFormatter
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()
}

public extension Calendar {
    static var currentGMT: Calendar {
        var cal = Calendar.current
        cal.timeZone = .gmt
        return cal
    }
    
    static let gregorian: Calendar = {
       return Calendar(identifier: .gregorian)
    }()
}

//MARK: Initialize
public extension Date {
     init(timeStamp: Int) {
        self.init(timeIntervalSince1970: Double(timeStamp))
    }
    
     init(day: Int,
                month: Int = Calendar.gregorian.component(.month, from: Date()),
                year: Int = Calendar.gregorian.component(.year, from: Date())) {
        var comps = DateComponents()
        comps.day = day
        comps.month = month
        comps.year = year
        self.init(timeInterval: 0, since: Calendar.gregorian.date(from: comps)!)
    }
    
     init?(from string: String, format: String, dateFormatter: DateFormatter = DateFormatter.shared) {
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: string) {
            self.init(timeInterval: 0, since: date)
        } else {
            return nil
        }
    }
}

//MARK: Extra
public extension Date {
     var year: Int {
        return self.getComponent(.year)
    }
    
     var month: Int {
        return self.getComponent(.month)
    }
    
     var day: Int {
        return self.getComponent(.day)
    }
    
     var hour: Int {
        return self.getComponent(.hour)
    }
    
     func getComponent(_ comp: Calendar.Component) -> Int {
         return Calendar.gregorian.component(comp, from: self)
    }
    
    static func dateAtMidnight() -> Date {
        let todayString = Date().toString("MM dd yyyy")+" 23:59:59"
        return Date(from: todayString, format: "MM dd yyyy HH:mm:ss")!
    }
    
     func startOfMonth() -> Date {
        return Calendar.gregorian.date(from: Calendar.gregorian.dateComponents([.year, .month], from: Calendar.gregorian.startOfDay(for: self)))!
    }
    
     func endOfMonth() -> Date {
        return Calendar.gregorian.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    /// Convert timeIntervalSinceNow to formatted string of date, `formatter` can be something like:
    /// ```
    /// let formatter = DateComponentsFormatter()
    /// formatter.unitsStyle = .abbreviated
    /// formatter.allowedUnits = [ .day, .hour, .minute, .second]
    /// ```
    ///
    /// - Parameter formatter: DateComponentsFormatter
    /// - Returns: formatted TimeInterval, like "1d 2h"
     func formattedTimeSinceNow(formatter: DateComponentsFormatter) -> String? {
        let duration = self.timeIntervalSinceNow
        return formatter.string(from: duration)
    }
}

//MARK: Conversion
public extension Date {
     func toTimeStamp() -> Int {
        return Int(self.timeIntervalSince1970)
    }
    
    //Convert Date to String
    func toString(_ format: String, dateFormatter: DateFormatter = DateFormatter.shared) -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    static func numberOfDayInYear(fromDate date: Date) -> Int {
        let oneYearFromCurrent = Date(day: date.day, month: date.month, year: date.year-1)
        return Date.numberOfDayInPeriod(fromDate: date, toDate: oneYearFromCurrent)
    }
    
    static func numberOfDayInPeriod(fromDate date: Date, toDate: Date) -> Int {
        let numberOfDays = Calendar.gregorian.dateComponents([.day], from: date, to: toDate).day!
        return numberOfDays < 0 ? numberOfDays * -1 : numberOfDays
    }
}

//MARK: Calculation
public extension Date {
     static func +(left: Date, right: (Calendar.Component,Int)) -> Date {
        let date = Calendar.gregorian.date(byAdding: right.0, value: right.1, to: left)
        return date!
    }
     static func -(left: Date, right: (Calendar.Component,Int)) -> Date {
        let date = Calendar.gregorian.date(byAdding: right.0, value: -right.1, to: left)
        return date!
    }
}

//MARK: Int+Calendar.Component
public extension Int {
     var day: (Calendar.Component,Int) {
        return (.day, self)
    }
     var year: (Calendar.Component,Int) {
        return (.year, self)
    }
     var month: (Calendar.Component,Int) {
        return (.month, self)
    }
     var hour: (Calendar.Component,Int) {
        return (.hour, self)
    }
     var minute: (Calendar.Component,Int) {
        return (.minute, self)
    }
     var second: (Calendar.Component,Int) {
        return (.second, self)
    }
}

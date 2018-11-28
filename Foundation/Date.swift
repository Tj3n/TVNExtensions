//
//  NSDateExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 3/17/16.
//  Copyright © 2016 Tien Nhat Vu. All rights reserved.
//

import Foundation

extension DateFormatter {
    /// Careful with date format change, should only be use to work with loop or collectionView,... to prevent recreated of DateFormatter
    static public let shared: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()
}

extension Calendar {
    static public var currentGMT: Calendar {
        var cal = Calendar.current
        cal.timeZone = .gmt
        return cal
    }
    
    static public let gregorian: Calendar = {
       return Calendar(identifier: .gregorian)
    }()
}

//MARK: Initialize
extension Date {
    public init(timeStamp: Int) {
        self.init(timeIntervalSince1970: Double(timeStamp))
    }
    
    public init(day: Int,
                month: Int = Calendar.gregorian.component(.month, from: Date()),
                year: Int = Calendar.gregorian.component(.year, from: Date())) {
        var comps = DateComponents()
        comps.day = day
        comps.month = month
        comps.year = year
        self.init(timeInterval: 0, since: Calendar.gregorian.date(from: comps)!)
    }
    
    public init?(from string: String, format: String, dateFormatter: DateFormatter = DateFormatter.shared) {
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: string) {
            self.init(timeInterval: 0, since: date)
        } else {
            return nil
        }
    }
}

//MARK: Extra
extension Date {
    public var year: Int {
        return self.getComponent(.year)
    }
    
    public var month: Int {
        return self.getComponent(.month)
    }
    
    public var day: Int {
        return self.getComponent(.day)
    }
    
    public var hour: Int {
        return self.getComponent(.hour)
    }
    
    public func getComponent(_ comp: Calendar.Component) -> Int {
         return Calendar.gregorian.component(comp, from: self)
    }
    
    static public func dateAtMidnight() -> Date {
        let todayString = Date().toString("MM dd yyyy")+" 23:59:59"
        return Date(from: todayString, format: "MM dd yyyy HH:mm:ss")!
    }
    
    public func startOfMonth() -> Date {
        return Calendar.gregorian.date(from: Calendar.gregorian.dateComponents([.year, .month], from: Calendar.gregorian.startOfDay(for: self)))!
    }
    
    public func endOfMonth() -> Date {
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
    public func formattedTimeSinceNow(formatter: DateComponentsFormatter) -> String? {
        let duration = self.timeIntervalSinceNow
        return formatter.string(from: duration)
    }
}

//MARK: Conversion
extension Date {
    public func toTimeStamp() -> Int {
        return Int(self.timeIntervalSince1970)
    }
    
    //Convert Date to String
    public func toString(_ format: String, dateFormatter: DateFormatter = DateFormatter.shared) -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    static public func numberOfDayInYear(fromDate date: Date) -> Int {
        let oneYearFromCurrent = Date(day: date.day, month: date.month, year: date.year-1)
        return Date.numberOfDayInPeriod(fromDate: date, toDate: oneYearFromCurrent)
    }
    
    static public func numberOfDayInPeriod(fromDate date: Date, toDate: Date) -> Int {
        let numberOfDays = Calendar.gregorian.dateComponents([.day], from: date, to: toDate).day!
        return numberOfDays < 0 ? numberOfDays * -1 : numberOfDays
    }
}

//MARK: Calculation
extension Date {
    public static func +(left: Date, right: (Calendar.Component,Int)) -> Date {
        let date = Calendar.gregorian.date(byAdding: right.0, value: right.1, to: left)
        return date!
    }
    public static func -(left: Date, right: (Calendar.Component,Int)) -> Date {
        let date = Calendar.gregorian.date(byAdding: right.0, value: -right.1, to: left)
        return date!
    }
}

//MARK: Int+Calendar.Component
public extension Int {
    public var day: (Calendar.Component,Int) {
        return (.day, self)
    }
    public var year: (Calendar.Component,Int) {
        return (.year, self)
    }
    public var month: (Calendar.Component,Int) {
        return (.month, self)
    }
    public var hour: (Calendar.Component,Int) {
        return (.hour, self)
    }
    public var minute: (Calendar.Component,Int) {
        return (.minute, self)
    }
    public var second: (Calendar.Component,Int) {
        return (.second, self)
    }
}

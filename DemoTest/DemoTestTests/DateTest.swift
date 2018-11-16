//
//  DateTest.swift
//  DemoTestTests
//
//  Created by Tien Nhat Vu on 4/11/18.
//

import XCTest
import TVNExtensions

class DateTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    let d = Date(day: 11, month: 4, year: 2018)
    
    func testNumberOfDays() {
        XCTAssertEqual(29, Date.numberOfDayInPeriod(fromDate: d.startOfMonth(), toDate: d.endOfMonth()))
    }
    
    func testDateFromString() {
        let dateFromString = Date(from: "11/04/2018", format: "dd/MM/yyyy")
        XCTAssertEqual(dateFromString, d)
        let dateFromWrongStr = Date(from: "11/04/2018", format: "dd-MMM-yyyy")
        XCTAssertEqual(dateFromWrongStr, nil)
    }
    
    func testDateToString() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        XCTAssertEqual(Date().toString("dd/MM/yyyy"), dateFormatter.string(from: Date()))
    }
    
    func testDateStartOfMonth() {
        XCTAssertEqual(d.startOfMonth(), Date(day: 1, month: 4, year: 2018))
    }
    
    func testEndOfMonth() {
        XCTAssertEqual(d.endOfMonth(), Date(day: 30, month: 4, year: 2018))
    }
    
    func testDateCalc() {
        XCTAssertEqual(d+1.day, Date(day: 12, month: 4, year: 2018))
        XCTAssertEqual(d-1.day, Date(day: 10, month: 4, year: 2018))
    }
}

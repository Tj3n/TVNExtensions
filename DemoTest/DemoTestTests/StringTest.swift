//
//  StringTest.swift
//  DemoTestTests
//
//  Created by Tien Nhat Vu on 4/11/18.
//

import XCTest
import TVNExtensions

class StringTest: XCTestCase {
    
    let s = "asdfqwer"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIndex() {
        XCTAssertEqual(String(s[s.index(fromStart: 3)]), "f")
        XCTAssertEqual(String(s[s.index(fromStart: -2)]), "a")
        XCTAssertEqual(String(s[s.index(fromStart: 30)]), "r")
        XCTAssertEqual(String(s[s.index(fromEnd: 3)]), "w")
        XCTAssertEqual(String(s[s.index(fromEnd: -2)]), "r")
        XCTAssertEqual(String(s[s.index(fromEnd: 30)]), "a")
    }
    
    func testSubscript() {
        XCTAssertEqual(s[2...4], "dfq")
        XCTAssertEqual(s[2..<4], "df")
        XCTAssertEqual(s[...4], "asdfq")
        XCTAssertEqual(s[4...], "qwer")
    }
    
    func testReplace() {
        XCTAssertEqual(s.replace(in: 2...4, with: "111"), "as111wer")
        XCTAssertEqual(s.replace(in: 2..<5, with: "111"), "as111wer")
    }
    
    func testFirstCharUppercase() {
        XCTAssertEqual(s.firstCharacterUppercase(), "Asdfqwer")
        XCTAssertEqual("a".firstCharacterUppercase(), "A")
        XCTAssertEqual("".firstCharacterUppercase(), "")
    }
    
    func testIsValidEmail() {
        XCTAssertFalse(s.isValidEmail())
        XCTAssertFalse("a@b.c".isValidEmail())
        
        XCTAssertTrue("a@b.co".isValidEmail())
        XCTAssertTrue("a+123@b.co".isValidEmail())
        XCTAssertTrue("a@b.co.vi".isValidEmail())
    }
    
    func testIsValidURL() {
        XCTAssertFalse(s.isValidURL())
        XCTAssertFalse("google.com".isValidURL())
        XCTAssertFalse("www.googl.com".isValidURL())
        
        XCTAssertTrue("http://www.google.com".isValidURL())
        XCTAssertTrue("https://google.com/asdf?zz=ss".isValidURL())
    }
    
    func testFormatDecimal() {
        XCTAssertEqual(s.formatDecimalString(numbersAfterDecimal: 2), "0.00")
        let n = "523456"
        XCTAssertEqual(n.formatDecimalString(numbersAfterDecimal: 1), "52345.6")
        XCTAssertEqual(n.formatDecimalString(numbersAfterDecimal: 2), "5234.56")
        XCTAssertEqual(n.formatDecimalString(numbersAfterDecimal: 8), "0.00523456")
        let n1 = "5.23456"
        XCTAssertEqual(n1.formatDecimalString(numbersAfterDecimal: 1), "52345.6")
    }
    
    func testCurrencySymbol() {
        XCTAssertEqual("USD".toCurrencySymbol(), "$")
        XCTAssertEqual("EUR".toCurrencySymbol(), "€")
        XCTAssertEqual("VND".toCurrencySymbol(), "₫")
        XCTAssertEqual("AUD".toCurrencySymbol(), "$")
        XCTAssertEqual("XBT".toCurrencySymbol(), "XBT")
    }
    
    func testCurrencyFormatter() {
        XCTAssertEqual("5.2345".toCurrencyFormatter(currencyCode: "USD"), "$5.23")
//        XCTAssertEqual("5.2345".toCurrencyFormatter(currencyCode: "XBT"), "XBT5.23") // in iOS 13 it become "XBT 5.23"
        XCTAssertEqual("5.2345".toCurrencyFormatter(currencyCode: "AUD"), "A$5.23")
        XCTAssertEqual(s.toCurrencyFormatter(currencyCode: "USD"), s)
    }
}

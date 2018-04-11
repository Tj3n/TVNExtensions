//
//  DemoTestTests.swift
//  DemoTestTests
//
//  Created by Tien Nhat Vu on 4/11/18.
//

import XCTest
@testable import DemoTest
import TVNExtensions

class DemoTestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testDictSort() {
        let dict = ["device_id": "FF200060-E509-4A01-B2EA-399AC1490383",
                    "people[offset]":"0",
                    "timestamp":"1521200863",
                    "token":"y5bG46Wz5zE6NUrxemPktxYgK",
                    "people[sort_by]":"email",
                    "people[sort_mode]":"asc"]
        let sorted = dict.sortToString(withAndCharacter: true)
        XCTAssertEqual(sorted, "device_id=FF200060-E509-4A01-B2EA-399AC1490383&people[offset]=0&people[sort_by]=email&people[sort_mode]=asc&timestamp=1521200863&token=y5bG46Wz5zE6NUrxemPktxYgK")
    }
    
    func testNSErrorToJSON() {
        let err = NSError(domain: "com.tvn.test", code: 500, userInfo: [NSLocalizedDescriptionKey: "somethingerror"])
        XCTAssertEqual(err.jsonString, "{\"description\":\"somethingerror\",\"code\":\"500\"}")
        let err2 = NSError(domain: "com.tvn.test", code: 500, userInfo: nil)
        XCTAssertEqual(err2.jsonString, "{\"description\":\"The operation couldn’t be completed. (com.tvn.test error 500.)\",\"code\":\"500\"}")
    }
    
    func testRand() {
        for _ in 0...100 {
            let a = Float.random(between: 5, and: 50)
            XCTAssertTrue(a >= 5.0 && a <= 50)
        }
    }
    
    func testToUSD() {
        let a = 5.23
        XCTAssertEqual(a.toUSD(), "$5.23")
    }
    
    func testRound() {
        let a = Decimal(string: "5.3262341234")!
        XCTAssertEqual(a.round(to: 2), Decimal(string: "5.33")!)
    }
    
    func testRad() {
        let a: CGFloat = 270.0
        XCTAssertEqual(a.toRad(), 4.71, accuracy: 1.0)
    }
    
}

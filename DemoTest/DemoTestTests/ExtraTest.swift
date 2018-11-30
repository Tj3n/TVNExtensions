//
//  ExtraTest.swift
//  DemoTestTests
//
//  Created by Tien Nhat Vu on 4/20/18.
//

import XCTest

class ExtraTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDictSort() {
        let dict = ["device_id": "FF200060-E509-4A01-B2EA-399AC1490383",
                    "people[offset]": "0",
                    "timestamp": "1521200863",
                    "token": "y5bG46Wz5zE6NUrxemPktxYgK",
                    "people[sort_by]": "email",
                    "people[sort_mode]": "asc"]
        let sorted = dict.sortToString(withAndCharacter: true)
        XCTAssertEqual(sorted, "device_id=FF200060-E509-4A01-B2EA-399AC1490383&people[offset]=0&people[sort_by]=email&people[sort_mode]=asc&timestamp=1521200863&token=y5bG46Wz5zE6NUrxemPktxYgK")
    }
    
    func testNSErrorToJSON() {
        let err = NSError(domain: "com.tvn.test", code: 500, userInfo: [NSLocalizedDescriptionKey: "somethingerror"])
        if let data = err.jsonString?.data(using: .utf8),
            let jsonObj = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let json = jsonObj {
            XCTAssertEqual(json["code"] as? String, "500")
            XCTAssertEqual(json["description"] as? String, "somethingerror")
        }

        let err2 = NSError(domain: "com.tvn.test", code: 500, userInfo: nil)
        if let data = err2.jsonString?.data(using: .utf8),
            let jsonObj = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let json = jsonObj {
            XCTAssertEqual(json["code"] as? String, "500")
            XCTAssertEqual(json["description"] as? String, "The operation couldn’t be completed. (com.tvn.test error 500.)")
        }
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

    func testSystemVersionCompaing() {
        XCTAssertEqual(UIDevice.compareSystemVersion(to: "20.0"), .less)
        XCTAssertEqual(UIDevice.compareSystemVersion(to: UIDevice.current.systemVersion), .equal)
        XCTAssertEqual(UIDevice.compareSystemVersion(to: "1.0"), .greater)
    }
}

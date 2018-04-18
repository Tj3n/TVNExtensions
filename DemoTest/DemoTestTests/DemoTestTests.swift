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
    
    func testDecodable() {
        let dict = ["object": "charge",
                    "id": "29131519199667_test",
                    "created": 1519199667,
                    "amount": "1",
                    "currency": "USD",
                    "refunded": false,
                    "captured": true,
                    "risk": "approved",
                    "card": [
                        "last4": "4242",
                        "type": "VISA",
                        "exp_month": "2",
                        "exp_year": "2018",
                        "country": "US",
                        "name": "TEST PAYER",
            ],
                    "secure": false,
                    "support_link": "http://example.com",
                    "test": 1,
                    "amount_paid": "1",
                    "currency_paid": "USD"] as [String: Any]
        
        let json = """
{
    "card": {
        "name": "TEST PAYER",
        "exp_year": "2018",
        "last4": "4242",
        "exp_month": "2",
        "type": "VISA",
        "country": "US"
    },
    "object": "charge",
    "risk": "approved",
    "amount_paid": "1",
    "support_link": "http://example.com",
    "amount": "1",
    "refunded": false,
    "captured": true,
    "id": "29131667_test",
    "created": 1519199667,
    "currency": "USD",
    "secure": false,
    "test": 1,
    "currency_paid": "USD"
}
""".data(using: .utf8)!
        
        let bundle = Bundle(for: DemoTestTests.self)
        let path = bundle.path(forResource: String(describing: ChargeObject.self), ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            XCTAssertNoThrow(try JSONDecoder().decode(ChargeObject.self, from: jsonData))
            XCTAssertNoThrow(try JSONDecoder().decode(ChargeObject.self, from: json))
            XCTAssertNoThrow(try JSONDecoder().decode(ChargeObject.self, from: data))
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
}


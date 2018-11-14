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
                    "support_link_asdf": "http://example.com",
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
    "support_link_asdf": "http://example.com",
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
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase //Or specify CodingKey struct and init(from decoder:_)
            
            XCTAssertNoThrow(try decoder.decode(ChargeObject.self, from: jsonData))
            XCTAssertNoThrow(try decoder.decode(ChargeObject.self, from: json))
            XCTAssertNoThrow(try decoder.decode(ChargeObject.self, from: data))
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testArray() {
        var a = [Test(obj: 1),Test(obj: 2),Test(obj: 1),Test(obj: 3),Test(obj: 1)]
        let t = Array(NSOrderedSet(array: a)) as! [Test]
        a = a.unique{$0.obj}
        
        XCTAssertEqual(a, t)
    }
}

//To use Set/NSOrderedSet
struct Test: Equatable, Hashable {
    let obj: Int
}

//Use Array
extension Array {
    func unique<T:Hashable>(map: ((Element) -> (T))) -> [Element] {
        var set = Set<T>()
        var arrayOrdered = [Element]()
        
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }
        return arrayOrdered
    }
}


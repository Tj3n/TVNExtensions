//
//  OtherTest.swift
//  DemoTestTests
//
//  Created by Tj3n-MacOS on 5/14/18.
//

import XCTest

class OtherTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func pickingNumbers(a: [Int]) -> Int {
        let b = a.sorted()
        let c = Set(b)
        var d = [[Int]]()
        c.forEach { (i) in
            var validJArray = [Int]()
            for j in b {
                if i-j <= 1 && i-j >= 0 {
                    validJArray.append(j)
                }
            }
            d.append(validJArray)
        }
        return d.map({ $0.count }).sorted().last ?? 0
    }
    
    func testPickingNumbers() {
        let a = pickingNumbers(a: [1, 2, 2, 3, 1, 2])
        XCTAssertEqual(a, 5)
        let b = pickingNumbers(a: [4, 6, 5, 3, 3, 1])
        XCTAssertEqual(b, 3)
    }
    
    func climbingLeaderboard(scores: [Int], alice: [Int]) -> [Int] {
        let scores = Array(NSOrderedSet(array: scores)) as! [Int]
        var result = [Int]()
        var currentPlace = 0
        for i in alice.reversed() {
            while currentPlace < scores.count, scores[currentPlace] > i {
                currentPlace += 1
            }
            result.append(currentPlace+1)
        }
        return result.reversed()
    }
    
    func testClimb() {
        let a = climbingLeaderboard(scores: [100, 100, 50, 40, 40, 20, 10], alice: [5, 25, 50, 120])
        XCTAssertEqual(a, [6, 4, 2, 1])
    }
    
    func saveThePrisoner(n: Int, m: Int, s: Int) -> Int {
        return (m+s-1)%n == 0 ? n : (m+s-1)%n
    }
    
    func testSavePrisoner() {
        let a = saveThePrisoner(n: 5, m: 2, s: 1)
        XCTAssertEqual(a, 2)
        let b = saveThePrisoner(n: 5, m: 2, s: 2)
        XCTAssertEqual(b, 3)
        let c = saveThePrisoner(n: 4, m: 6, s: 2)
        XCTAssertEqual(c, 3)
        let d = saveThePrisoner(n: 352926151, m: 380324688, s: 94730870)
        XCTAssertEqual(d, 122129406)
        let e = saveThePrisoner(n: 3, m: 4, s: 3)
        XCTAssertEqual(e, 3)
    }
    
    func circularArrayRotation(n: Int, k: Int, q: Int, a: [Int], m: [Int]) -> [Int] {
        let rotTimes = n-k%n
        return m.map({ a[rotTimes+$0 >= n ? rotTimes+$0-n : rotTimes+$0] })
    }
    
    func testCircular() {
        let a = circularArrayRotation(n: 3, k: 1, q: 3, a: [1, 2, 3], m: [0, 1, 2])
        XCTAssertEqual(a, [3,1,2])
        let b = circularArrayRotation(n: 51, k: 51, q: 3, a: [39356, 87674, 16667, 54260, 43958, 70429, 53682, 6169, 87496, 66190, 90286, 4912, 44792, 65142, 36183, 43856, 77633, 38902, 1407, 88185, 80399, 72940, 97555, 23941, 96271, 49288, 27021, 32032, 75662, 69161, 33581, 15017, 56835, 66599, 69277, 17144, 37027, 39310, 23312, 24523, 5499, 13597, 45786, 66642, 95090, 98320, 26849, 72722, 37221, 28255, 60906], m: [47, 10, 12])
        XCTAssertEqual(b, [72722 ,90286 ,44792])
    }
    
    func factorial(_ n: Int) -> String {
        var result = [1]
        guard n > 1 else { return String(n) }
        for i in 2...n {
            print(result)
            result = result.map { $0 * i }
            result = splitNumToArray(result)
        }
        return result.map({String($0)}).joined()
    }
    
    func splitNumToArray(_ array: [Int]) -> [Int] {
        var result: [Int] = [Int]()
        
        var added = 0
        for i in array.reversed() {
            let total = i + added
            let digit = total % 10
            added = total / 10
            result.append(digit)
        }
        
        while added > 0 {
            let digit = added % 10
            added = added / 10
            result.append(digit)
        }
        return result.reversed()
    }
    
    func testFactorial() {
        let a = factorial(58)
        XCTAssertEqual(a, "2350561331282878571829474910515074683828862318181142924420699914240000000000000")
    }
}

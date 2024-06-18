import XCTest
@testable import Geometry

final class CGRectTests: XCTestCase {
    func testItReturnsLocationsWithinIt() {
        let r1 = CGRect(origin: .init(0, 0), size: .init(100, 100))
        
        XCTAssert(r1.at(.min, .min) == CGPoint(0, 0))
        XCTAssert(r1.at(.max, .max) == CGPoint(100, 100))
        XCTAssert(r1.at(.mid, .max) == CGPoint(50, 100))
    }
    
    func testItCanBeInitializedFromPoints() {
        let p0 = CGPoint(0, 0)
        let p1 = CGPoint(50, 50)
        let p2 = CGPoint(100, 100)
        
        let r1 = CGRect(p0)
        
        XCTAssert(r1.origin == p0)
        XCTAssert(r1.size   == .zero)
        
        let r2 = CGRect(p0, p1)
        
        XCTAssert(r2.origin == p0)
        XCTAssert(r2.size == CGSize(p1 - p0))
        
        let r3 = CGRect(p0, p1, p2)
        
        XCTAssert(r3.origin == p0)
        XCTAssert(r3.size == CGSize(p2 - p0))
        
        XCTAssert(r3.contains(p1))
    }
}

final class CGVectorTypeTests: XCTestCase {
    func testVectorTypesCanBeConverted() {
        let p1 = CGPoint(1, 2)
        let s2 = CGSize(p1)
        
        XCTAssert(s2.width == 1 && s2.height == 2)
    }
    
    func testVectorTypesOfferCommonOperators() {
        let s1 = CGSize(100, 100)
        
        XCTAssert(s1 * 2 == CGSize(200, 200))
        XCTAssert(s1 + (0, 5) == CGSize(100, 105))
        XCTAssert(s1 * (1, 0.5) == CGSize(100, 50))
        
        XCTAssert(s1 / 2 == CGSize(50, 50))
        XCTAssert(s1 - (0, 5) == CGSize(100, 95))
        XCTAssert(s1 / (1, 0.5) == CGSize(100, 100))
    }
}

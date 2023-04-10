//
//  ItemElementsCreatorTests.swift
//  MoreGreenTests
//
//  Created by Kyus'lee on 2023/03/20.
//

import XCTest
@testable import MoreGreen

final class ItemElementsCreatorTests: XCTestCase {
    
    let creator = ItemElementsCreator()
    
    func testResult1() {
        let recognizedexpirationDate = "2023-3-21"
        let expirationDate = creator.create(from: recognizedexpirationDate)
        
        XCTAssertEqual(expirationDate.expirationDate, "2023-3-21")
    }
    
    func testResult2() {
        let recognizedexpirationDate = "23-03-21"
        let expirationDate = creator.create(from: recognizedexpirationDate)
        
        XCTAssertEqual(expirationDate.expirationDate, "23-03-21")
    }
    
    func testResult3() {
        let recognizedexpirationDate = "23-3-1"
        let expirationDate = creator.create(from: recognizedexpirationDate)
        
        XCTAssertEqual(expirationDate.expirationDate, "23-3-1")
    }
    
    func testResult4() {
        let recognizedexpirationDate = "2023/3/21"
        let expirationDate = creator.create(from: recognizedexpirationDate)
        
        XCTAssertEqual(expirationDate.expirationDate, "2023/3/21")
    }
    
    func testResult5() {
        let recognizedexpirationDate = "2023/3/1"
        let expirationDate = creator.create(from: recognizedexpirationDate)
        
        XCTAssertEqual(expirationDate.expirationDate, "2023/3/1")
    }
    
    func testResult6() {
        let recognizedexpirationDate = "23/3/1"
        let expirationDate = creator.create(from: recognizedexpirationDate)
        
        XCTAssertEqual(expirationDate.expirationDate, "23/3/1")
    }
    
    func testResult7() {
        let recognizedexpirationDate = "23/03/01"
        let expirationDate = creator.create(from: recognizedexpirationDate)
        
        XCTAssertEqual(expirationDate.expirationDate, "23/03/01")
    }
    
    func testResult8() {
        let recognizedexpirationDate = "2023.03.01"
        let expirationDate = creator.create(from: recognizedexpirationDate)
        
        XCTAssertEqual(expirationDate.expirationDate, "2023.03.01")
    }
    
//    // 数字と年月日が混ざっている文字列は認識されないことを確認した
//    func testResult9() {
//        let recognizedexpirationDate = "2023年03月01日"
//        let expirationDate = creator.create(from: recognizedexpirationDate)
//
//        XCTAssertEqual(expirationDate.expirationDate, "2023年03月01日")
//    }
    
    // 以下賞味期限と日本語、数字が混ざっている時
    func testResult10() {
        let recognizedexpirationDate = "2023/3/21\n賞味期限"
        let expirationDate = creator.create(from: recognizedexpirationDate)
        
        XCTAssertEqual(expirationDate.expirationDate, "2023/3/21")
    }
    
    func testResult11() {
        let recognizedexpirationDate = "22212\n2023/3/21\n賞味期限"
        let expirationDate = creator.create(from: recognizedexpirationDate)
        
        XCTAssertEqual(expirationDate.expirationDate, "2023/3/21")
    }
}

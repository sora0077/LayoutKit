//
//  LayoutKitTests.swift
//  LayoutKitTests
//
//  Created by 林 達也 on 2015/01/11.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit
import XCTest
//import LayoutKit

class DummyDelegate: NSObject, UITableViewDelegate {

}

class LayoutKitTests: XCTestCase {
    
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
        XCTAssert(true, "Pass")

        let cell = UITableViewCell(style: .Default, reuseIdentifier: "")

        let row = TableRowElement()
        cell.rowElement = row

        XCTAssertEqual(cell.rowElement!.dynamicType.identifier, "a", "")
    }

    func test_テーブルビューの入れ替えが正しく行われること() {

        let tableView = UITableView(frame: CGRectZero, style: .Plain)
        let initialDelegate = DummyDelegate()

        tableView.delegate = initialDelegate

        tableView.controller = TableController()

        XCTAssertTrue(tableView.delegate! === tableView.controller!, "")

        tableView.controller = nil

        XCTAssertTrue(tableView.delegate! === initialDelegate, "")


    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}

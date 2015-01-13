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

class TextRow<T: UITableViewCell>: TableRowRendererElement<T> {

    private var title: String

    private var willAppeared: Bool = false
    private var didAppeared: Bool = false

    private var willDisappeared: Bool = false
    private var didDisappeared: Bool = false

    init(title: String) {
        self.title = title

        super.init()
    }

    override func viewWillAppear() {
        self.willAppeared = true
    }

    override func viewDidAppear() {
        self.didAppeared = true
    }

    override func viewWillDisappear() {
        self.willDisappeared = true
    }

    override func viewDidDisappear() {
        self.didDisappeared = true
    }
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

//        let cell = UITableViewCell(style: .Default, reuseIdentifier: "")
//
//        let row = TableRowElement()
//        cell.rowElement = row
//
//        XCTAssertEqual(cell.rowElement!.dynamicType.identifier, "a", "")
    }

    func test_テーブルビューの入れ替えが正しく行われること() {

        let tableView = UITableView(frame: CGRectZero, style: .Plain)
        let initialDelegate = DummyDelegate()

        tableView.delegate = initialDelegate

        let controller = TableController()
        tableView.controller = controller

        XCTAssertTrue(tableView.delegate! === tableView.controller!, "")

        let altController = TableController()

        tableView.controller = altController

        XCTAssertTrue(tableView.delegate! === altController, "")
        XCTAssertTrue(altController.altDelegate === initialDelegate, "コントローラの入れ替えは元の管理外のオブジェクトに戻る")

        tableView.controller = nil

        XCTAssertTrue(tableView.delegate! === initialDelegate, "")


    }

    func test_() {

        let row = TextRow<UITableViewCell.StyleDefault>(title: "test")
        let controller = TableController()
        let tableView = UITableView(frame: CGRectZero, style: .Plain)

        XCTAssertEqual(1, controller.sections.count, "")

        tableView.controller = controller

        controller[0].append(row)


        XCTAssertEqual(1, controller.sections[0].rows.count, "")

        XCTAssertFalse(row.willAppeared, "")

        tableView.reloadData()
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
//        controller.tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)

        XCTAssertTrue(row.willAppeared, "")
        println(row)
        println(row.renderer)
        XCTAssertNotNil(row.renderer, "")

        let altRow = TextRow<UITableViewCell.StyleDefault>(title: "alt")
        row.replace(to: altRow)

        tableView.cellForRowAtIndexPath(indexPath)!

        let expect = self.expectationWithDescription("replace")
        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            XCTAssertTrue(row.didDisappeared, "")
            XCTAssertNil(row.renderer, "")
            XCTAssertNotNil(altRow.renderer, "")

            expect.fulfill()
        })

        self.waitForExpectationsWithTimeout(3, handler: { (error) -> Void in

        })
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}

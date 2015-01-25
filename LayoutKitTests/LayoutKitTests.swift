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

class TextRow<T: UITableViewCell where T: TableElementRendererProtocol>: TableRow<T> {

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

extension XCTestCase {

    func async(_ expire: NSTimeInterval = 10, _ queue: dispatch_queue_t = dispatch_get_main_queue(), delay: NSTimeInterval = 0, description: String, _ block: () -> Void) {

        let expect = self.expectationWithDescription(description)
        let delay = delay * Double(NSEC_PER_SEC)
        let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

        dispatch_after(time, queue) {
            block()

            expect.fulfill()
        }

        self.waitForExpectationsWithTimeout(expire, handler: { (error) -> Void in
            
        })
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

    func test_テーブルビューの入れ替えが正しく行われること() {

        let tableView = UITableView(frame: CGRectZero, style: .Plain)
        let initialDelegate = DummyDelegate()

        tableView.delegate = initialDelegate

        let controller = TableController(responder: nil)
        tableView.controller = controller

        XCTAssertTrue(tableView.delegate! === tableView.controller!, "")

        let altController = TableController(responder: nil)

        tableView.controller = altController

        XCTAssertTrue(tableView.delegate! === altController, "")
        XCTAssertTrue(altController.altDelegate === initialDelegate, "コントローラの入れ替えは元の管理外のオブジェクトに戻る")

        tableView.controller = nil

        XCTAssertTrue(tableView.delegate! === initialDelegate, "")


    }

    func test_セルの追加の動作() {

        let row = TextRow<UITableViewCell.StyleDefault>(title: "test")
        let controller = TableController(responder: nil)
        let tableView = UITableView(frame: CGRectZero, style: .Plain)


        tableView.controller = controller
        controller.sections[0].append(row)

        XCTAssertEqual(0, controller.sections[0].rows.count, "追加直後は反映されていない")

        controller.invalidate()
        XCTAssertEqual(1, controller.sections[0].rows.count, "invalidate()は強制的に再描画を行う")

    }

    func test_セルの入れ替えでrendererとフラグがそれぞれの状態になっているか() {

        let row = TextRow<UITableViewCell.StyleDefault>(title: "test")
        let controller = TableController(responder: nil)
        let tableView = UITableView(frame: CGRectZero, style: .Plain)


        tableView.controller = controller
        controller.sections[0].append(row)

        XCTAssertFalse(row.willAppeared, "")

        controller.invalidate()

        tableView.reloadData()
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)

        tableView.cellForRowAtIndexPath(indexPath)

        XCTAssertTrue(row.willAppeared, "")
        XCTAssertNotNil(row.renderer, "")

        let altRow = TextRow<UITableViewCell.StyleDefault>(title: "alt")
        row.replace(to: altRow)

        tableView.cellForRowAtIndexPath(indexPath)

        self.async(delay: 2, description: "") {

            XCTAssertTrue(row.didDisappeared, "")
            XCTAssertNil(row.renderer, "")
            XCTAssertNotNil(altRow.renderer, "")

            XCTAssertEqual(altRow, controller.sections[0].rows[0], "")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}

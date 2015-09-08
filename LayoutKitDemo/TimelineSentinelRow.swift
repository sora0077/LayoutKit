//
//  TimelineSentinelRow.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/22.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit
import LayoutKit


class TimelineSentinelRow
    <T: UITableViewCell where T: TableElementRendererProtocol>: TableRow<T> {

    typealias SelfType = TimelineSentinelRow

    let trigger: () -> Void
    var loading: Bool = false

    init(_ block: () -> Void) {
        self.trigger = block
        super.init()
    }

    override func viewDidLayoutSubviews() {

        self.loadingDidStart(0)
    }

    func loadingDidStart(done: NSTimeInterval = 0) {

        if !self.loading {
            self.loading = true

            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(done * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.remove()

                self.trigger()
            }
        }
    }
}

class _TimelineInvisibleSentinelRow
    <T: UITableViewCell where T: TableElementRendererProtocol>: TimelineSentinelRow<T> {

    override init(_ block: () -> Void) {

        super.init(block)
        self.size.height = 0
    }
}

typealias TimelineInvisibleSentinelRow = _TimelineInvisibleSentinelRow<UITableViewCell.StyleDefault>



class _TimelineLoadingSentinelRow
    <T: UITableViewCell where T: TableElementRendererProtocol>: TimelineSentinelRow<T> {

    override init(_ block: () -> Void) {

        super.init(block)

    }

    override func viewDidLayoutSubviews() {

        self.loadingDidStart(1)

        self.renderer?.textLabel?.text = "読み込み中..."

    }
}

typealias TimelineLoadingSentinelRow = _TimelineLoadingSentinelRow<UITableViewCell.StyleDefault>

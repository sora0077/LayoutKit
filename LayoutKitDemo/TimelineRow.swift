//
//  TimelineRow.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/22.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit
import LayoutKit

class TimelineRow<T: UITableViewCell where T: TableElementRendererProtocol>: TableRowRendererElement<T> {

    private let title: String

    init(title: String = "") {
        self.title = title
        super.init()
    }

    override func viewDidAppear() {

        self.renderer?.textLabel?.text = "cell \(self.title)"
    }
}

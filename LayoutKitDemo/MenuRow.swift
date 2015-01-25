//
//  MenuRow.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/21.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit
import LayoutKit

class MenuRow<T: UITableViewCell where T: TableElementRendererProtocol>: TableRow<T> {

    private let title: String
    private let action: () -> Void

    init(title: String, _ action: () -> Void) {
        self.title = title
        self.action = action

        super.init()
    }

    override func viewDidAppear() {

        self.renderer?.textLabel?.text = self.title
    }

    override func didSelect() {
        super.didSelect()

        self.action()
    }
}

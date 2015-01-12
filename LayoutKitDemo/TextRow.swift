//
//  TextRow.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/12.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit
import LayoutKit

class TextRow<T: UITableViewCell>: TableRowRendererElement<T> {

    private var title: String

    init(title: String) {
        self.title = title

        super.init()
    }

    override func viewWillAppear() {

//        println(("viewWillAppear", self.renderer))

    }

    override func viewDidAppear() {

//        println(("viewDidAppear", self.renderer))

        self.renderer?.textLabel?.text = self.title
        self.renderer?.detailTextLabel?.text = "aaa"
    }

    override func viewWillDisappear() {

//        println(("viewWillDisappear", self.renderer))
    }

    override func viewDidDisappear() {

//        println(("viewDidDisappear", self.renderer))
    }

    override func didSelect() {

//        self.replace()
        self.replace(to: TextRow<UITableViewCell.StyleValue2>(title: "replaced"))
    }
}



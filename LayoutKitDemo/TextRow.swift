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

        println(("viewWillAppear", self.title))

    }

    override func viewDidAppear() {

        println(("viewDidAppear", self.title))

        self.renderer?.textLabel?.text = self.title
        self.renderer?.detailTextLabel?.text = "aaa"
    }

    override func viewWillDisappear() {

        println(("viewWillDisappear", self.title))
        self.renderer?.detailTextLabel?.text = "nnn"
    }

    override func viewDidDisappear() {

        println(("viewDidDisappear", self.title))
    }

    override func didSelect() {

//        self.size.height = 100
//        self.replace()
        let row = TextRow<UITableViewCell.StyleValue2>(title: "replaced")
//        row.size.height = self.renderer!.frame.height * 1.1
        self.replace(to: row)
    }
}



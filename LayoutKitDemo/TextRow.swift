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

    private let title: String

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
}

class TextViewCell: UITableViewCell {

    override class var identifier: String {
        return "TextViewCell"
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value2, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  TextRow.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/12.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit
import LayoutKit

protocol TextRowRendererAcceptable: TableElementRendererProtocol {

    weak var titleLabel: UILabel! { get }
}

class TextRow<T: UITableViewCell where T: TextRowRendererAcceptable>: TableRowRendererElement<T> {

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

        self.renderer?.titleLabel.text = self.title
    }

    override func viewWillDisappear() {

        println(("viewWillDisappear", self.title))
    }

    override func viewDidDisappear() {

        println(("viewDidDisappear", self.title))
    }

    override func didSelect() {

//        self.size.height = 100
//        self.replace()
        let row = TextRow<ColoredTextTableViewCell>(title: "replaced \(self.title)")
        row.size.height = 60
//        row.size.height = self.renderer!.frame.height * 1.1
        self.replace(to: row)
    }
}



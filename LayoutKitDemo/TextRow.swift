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

class TextRow<T: UITableViewCell where T: TextRowRendererAcceptable>: TableRow<T> {

    var title: String {
        willSet {
            self.renderer?.titleLabel.text = newValue
        }
    }

    init(title: String) {
        self.title = title

        super.init()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        println(("viewDidAppear", self.renderer))

        self.renderer?.titleLabel.text = self.title
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        println(("viewWillDisappear", self.renderer))
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()

//        println(("viewDidDisappear", self.renderer))
    }

    override func didSelect() {
        super.didSelect()
//        self.size.height = 100
//        self.replace()
        let row = TextRow<ColoredTextTableViewCell>(title: "replaced \(self.title)")
        row.size.height = 60
//        row.size.height = self.renderer!.frame.height * 1.1
        self.replace(to: row)
    }
}



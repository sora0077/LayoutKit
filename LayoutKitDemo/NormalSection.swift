//
//  NormalSection.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/15.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit
import LayoutKit

class NormalSection<T: UITableViewHeaderFooterView>: TableHeaderFooter<T> {

    private let title: String

    init(title: String, height: CGFloat = 40) {
        self.title = title

        super.init()

        self.size.height = height
    }

    override func viewWillAppear() {

        self.renderer?.contentView.backgroundColor = UIColor.blueColor()
//        self.renderer?.textLabel.text = self.title

    }

}

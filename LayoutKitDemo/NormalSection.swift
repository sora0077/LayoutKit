//
//  NormalSection.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/15.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit
import LayoutKit

class NormalSection<T: UITableViewHeaderFooterView>: TableSectionRendererElement<T> {

    override init() {
        super.init()

        self.size.height = 20
    }


    override func viewDidAppear() {

//        self.renderer?.contentView.backgroundColor = UIColor.blueColor()
        self.renderer?.textLabel.text = "header"
    }

}

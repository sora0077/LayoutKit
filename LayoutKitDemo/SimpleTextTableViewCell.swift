//
//  SimpleTextTableViewCell.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/15.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit

class SimpleTextTableViewCell: UITableViewCell, TextRowRendererAcceptable {

    @IBOutlet weak var titleLabel: UILabel!

    class var identifier: String {
        return "SimpleTextTableViewCell"
    }

    class var canRegister: Bool {
        return true
    }

    class func register(tableView: UITableView) {

        tableView.registerNib(UINib(nibName: self.identifier, bundle: nil), forCellReuseIdentifier: self.identifier)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

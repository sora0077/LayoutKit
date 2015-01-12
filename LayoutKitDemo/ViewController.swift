//
//  ViewController.swift
//  LayoutKitDemo
//
//  Created by 林 達也 on 2015/01/11.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit
import LayoutKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.tableView.controller = TableController()
        self.tableView.controller?[0].append(TextRow<UITableViewCell>(title: "test"))
        self.tableView.controller?[0].append(TextRow<UITableViewCell>(title: "test1"))
        self.tableView.controller?[0].append(TextRow<UITableViewCell.StyleSubtitle>(title: "test2"))
        self.tableView.controller?[0].append(TextRow<UITableViewCell.StyleValue1>(title: "test3"))
        self.tableView.controller?[0].append(TextRow<UITableViewCell.StyleValue2>(title: "test4"))

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


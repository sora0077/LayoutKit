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
        if let c = self.tableView.controller {
            c[0].append(TextRow<UITableViewCell.StyleDefault>(title: "test1"))
            c[0].append(TextRow<UITableViewCell.StyleSubtitle>(title: "test2"))
            c[0].append(TextRow<UITableViewCell.StyleValue1>(title: "test3"))
            c[0].append(TextRow<UITableViewCell.StyleValue2>(title: "test4"))
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let delay = 3.0 * Double(NSEC_PER_SEC)
        let when  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(when, dispatch_get_main_queue()) { () -> Void in

            if let c = self.tableView.controller {
                for i in 0..<100 {
                    c[0].append(TextRow<UITableViewCell.StyleValue2>(title: "test\(i+5)"))
                }
            }
            let when  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(when, dispatch_get_main_queue()) { () -> Void in

                if let c = self.tableView.controller {
                    for r in enumerate(c[0].rows) {
                        if r.index % 2 == 0 {
                            r.element.replace()
                        } else {
                            r.element.remove()
                        }
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


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
            c.sections[0].append(TextRow<ColoredTextTableViewCell>(title: "test1"))
            c.sections[0].append(TextRow<SimpleTextTableViewCell>(title: "test2"))
            c.sections[0].append(TextRow<ColoredTextTableViewCell>(title: "test3"))
            c.sections[0].append(TextRow<SimpleTextTableViewCell>(title: "test4"))
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let delay = 3.0 * Double(NSEC_PER_SEC)
        let when  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(when, dispatch_get_main_queue()) { () -> Void in

            if let c = self.tableView.controller {
                var section: BlankSection! = BlankSection()
                section.header = NormalSection<UITableViewHeaderFooterView>()
                c.append(section)
                for i in 0..<100 {
                    let row = TextRow<SimpleTextTableViewCell>(title: "test\(i)")
                    section.append(row)
//                    if i % 3 == 0 {
//
//                        section.remove(row)
//                    }
                }
            }
            let when  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(when, dispatch_get_main_queue()) { () -> Void in

                if let c = self.tableView.controller {
                    for s in c.sections {
                        for r in enumerate(s.rows) {
                            switch r.index % 4 {
                            case 0:
                                break
                            case 1:
                                r.element.didSelect()
                            case 2:
                                r.element.remove()
                            case 3:
                                r.element.remove()
                            default:
                                break
                            }
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


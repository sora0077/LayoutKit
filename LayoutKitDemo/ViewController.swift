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

        self.tableView.controller = TableController(responder: self)
        if let c = self.tableView.controller {
            c.sections[0].extend(
                [
                    TextRow<ColoredTextTableViewCell>(title: "test1"),
//                    TextRow<SimpleTextTableViewCell>(title: "test2"),
//                    TextRow<ColoredTextTableViewCell>(title: "test3"),
//                    TextRow<SimpleTextTableViewCell>(title: "test4"),
                ]
            )
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let queue = dispatch_queue_create("aaa", nil)

        let delay = 3.0 * Double(NSEC_PER_SEC)
        let when  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(when, queue) { () -> Void in

            if let c = self.tableView.controller {
                for j in 0..<10 {
                    var section = TableSection()
                    if j % 2 == 0 {
                        c.append(section)
                    }
                    for i in 0..<40 {
                        let row = TextRow<SimpleTextTableViewCell>(title: "test\(i)")
                        section.append(row)
                    }
                    if j % 2 == 1 {
                        c.append(section)
                    }
                    section.footer = NormalSection<UITableViewHeaderFooterView>(title: "footer", height: 6)
                }
            }
            let when  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(when, queue) { () -> Void in

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
                let when  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(when, queue) { () -> Void in

                    if let c = self.tableView.controller {

                        let target = c.sections[0].rows[0]
                        let into = c.sections[1].rows[0]

                        
                        if let t = target as? TextRow<ColoredTextTableViewCell> {
                            t.title = "move move "
                        }

                        target.remove()
                        into.append(target)

                    }
                    let when  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                    dispatch_after(when, queue) { () -> Void in

                        if let c = self.tableView.controller {

                            let target = c.sections[1].rows[0]
                            target.size.height = 90
                        }
                        let when  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        dispatch_after(when, queue) { () -> Void in

                            if let c = self.tableView.controller {

                                c.removeAll()
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


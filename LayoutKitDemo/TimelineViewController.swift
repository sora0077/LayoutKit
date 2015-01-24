//
//  TimelineViewController.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/22.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit
import LayoutKit

class TimelineViewController: UIViewController {

    enum UIType {

        case Invisible
        case UI

        func appendRows(section: TableSection, vc: TimelineViewController) {

            section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
            section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
            switch self {
            case .Invisible:

                section.append(
                    TimelineInvisibleSentinelRow { [weak vc] in
                        vc?.appendRow()
                        return
                    }
                )

                section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
                section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
                section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
                section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
                section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
                section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
                section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
                section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
                return
            case .UI:
                section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
                section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
                section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
                section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
                section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
                section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
                section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
                section.append(TimelineRow<UITableViewCell.StyleDefault>(title: "\(vc.idx++)"))
                section.append(
                    TimelineLoadingSentinelRow { [weak vc] in
                        vc?.appendRow()
                        return
                    }
                )
            }
        }
    }

    @IBOutlet weak var tableView: UITableView!

    var uiType: UIType = .UI

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.tableView.controller = TableController(responder: self)
        self.appendRow()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private var idx = 0
    func appendRow() {

        if let c = self.tableView.controller {
            self.uiType.appendRows(c.sections[0], vc: self)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

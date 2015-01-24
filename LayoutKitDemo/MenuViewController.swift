//
//  MenuViewController.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/21.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit
import LayoutKit

class MenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.nextResponder()
        self.tableView.controller = TableController(responder: self)
        if let c = self.tableView.controller {
            c.sections[0].append(
                MenuRow<UITableViewCell.StyleDefault>(title: "セルの大量追加・削除・置換") { [unowned self] in
                    self.segueAction("ViewController")
                }
            )
            c.sections[0].append(
                MenuRow<UITableViewCell.StyleDefault>(title: "セルの追加読み込み"){ [unowned self] in
                    self.segueAction("TimelineViewController") {
                        if let vc = $0 as? TimelineViewController {
                            vc.uiType = .Invisible
                        }
                    }
                }
            )
            c.sections[0].append(
                MenuRow<UITableViewCell.StyleDefault>(title: "セルの追加読み込み UI付き"){ [unowned self] in
                    self.segueAction("TimelineViewController") {
                        if let vc = $0 as? TimelineViewController {
                            vc.uiType = .UI
                        }
                    }
                }
            )
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func segueAction(identifier: String, _ block: ((UIViewController) -> Void)? = nil) {

        let next = self.storyboard?.instantiateViewControllerWithIdentifier(identifier) as UIViewController
        self.navigationController?.pushViewController(next, animated: true)

        block?(next)
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

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
        
//        TableRowProtocol
        

        // Do any additional setup after loading the view.
        self.nextResponder()
        self.tableView.controller = TableController(responder: self)
        if let c = self.tableView.controller {
            c.sections[0].footer = NormalSection<UITableViewHeaderFooterView>(title: "footer", height: 10)
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
            c.sections[0].append(
                UITableView.StyleDefaultRow(text: "test")
            )
            c.sections[0].append(
                UITableView.StyleValue1Row(text: "test", detailText: "aa")
            )
            c.sections[0].append(
                UITableView.StyleValue2Row(text: "test", detailText: "aa")
            )
            c.sections[0].append(
                UITableView.StyleSubtitleRow(text: "test", detailText: "aa")
            )

            let s = TableSection()
            c.append(s)
            s.append(
                MenuRow<UITableViewCell.StyleDefault>(title: "セルの追加読み込み UI付き"){ [unowned self] in
                    self.segueAction("TimelineViewController") {
                        if let vc = $0 as? TimelineViewController {
                            vc.uiType = .UI
                        }
                    }
                }
            )

            let delay = 3.0 * Double(NSEC_PER_SEC)
            let when  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(when, dispatch_get_main_queue()) {
                print("aaaaaaa")
                s.footer = NormalSection<UITableViewHeaderFooterView>(title: "footer", height: 40)
            }
        }
        self.tableView.controller.invalidate()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func segueAction(identifier: String, _ block: ((UIViewController) -> Void)? = nil) {

        let next = self.storyboard!.instantiateViewControllerWithIdentifier(identifier)
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


extension MenuViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        print(scrollView.contentOffset)
    }
}
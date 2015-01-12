//
//  TableRowElement.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/11.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit



public class TableRowElement: LayoutElement {

    var index: (Int, Int) = (0, 0)

    class func register(tableView: UITableView) {
        fatalError("")
    }

    override public init() {
        super.init()
        
        self.size.height = UITableViewAutomaticDimension
    }

    func setRendererView(renderer: UITableViewCell?) {

    }

    func reload() {
        
    }
}

public class TableRowRendererElement<T: UITableViewCell>: TableRowElement, RendererProtocol {

    typealias Renderer = T

    override class var identifier: String {
        return T.identifier
    }

    override class var canRegister: Bool {
        return T.canRegister
    }

    override class func register(tableView: UITableView) {
        T.register(tableView)
    }

    public var renderer: Renderer? {

        willSet {
            if newValue != self.renderer {
                if self.renderer != nil {
                    self.viewWillDisappear()
                }
            }
            newValue?.rowElement?.viewWillAppear()
        }

        didSet {
            if oldValue != self.renderer {
                oldValue?.rowElement?.viewDidDisappear()
            }

            if self.renderer != nil {
                self.viewDidAppear()
            }
        }
    }

    override public init() {
        super.init()
    }

    override func setRendererView(renderer: UITableViewCell?) {

        if let renderer = renderer {
            self.renderer = renderer as? Renderer
        } else {
            self.renderer = nil
        }
    }
}


private var UITableViewCell_rowElement: UInt8 = 0
extension UITableViewCell: TableElementRendererClass {

    public class var identifier: String {
        return "UITableViewCell"
    }

    public class var canRegister: Bool {
        return true
    }

    public class func register(tableView: UITableView) {

        tableView.registerClass(self, forCellReuseIdentifier: self.identifier)
    }

    var rowElement: TableRowElement? {

        get {
            let val: AnyObject! = objc_getAssociatedObject(self, &UITableViewCell_rowElement)

            return val as? TableRowElement
        }

        set {
            objc_setAssociatedObject(self, &UITableViewCell_rowElement, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
}



extension UITableViewCell {

    public class StyleDefault: UITableViewCell {

        override public class var identifier: String {
            return "UITableViewCell.StyleDefault"
        }
    }

    public class StyleValue1: UITableViewCell {

        override public class var identifier: String {
            return "UITableViewCell.StyleValue1"
        }

        override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        }

        required public init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }

    public class StyleValue2: UITableViewCell {

        override public class var identifier: String {
            return "UITableViewCell.StyleValue2"
        }

        override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .Value2, reuseIdentifier: reuseIdentifier)
        }

        required public init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }

    public class StyleSubtitle: UITableViewCell {

        override public class var identifier: String {
            return "UITableViewCell.StyleSubtitle"
        }

        override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        }

        required public init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
}

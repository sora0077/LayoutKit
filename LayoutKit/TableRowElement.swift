//
//  TableRowElement.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/11.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit

public class TableRowElement: LayoutElement {

    /// section, row
    var index: (Int, Int) {
        let section = self.section!.index
        let index = find(self.section!.rows, self)!
        return (section, index)
    }

    public var accessoryType: UITableViewCellAccessoryType = .None
    public var selectionStyle: UITableViewCellSelectionStyle = .Default
    public var autoDeselect: Bool = true

    weak var section: TableSection?

    class func register(tableView: UITableView) {

    }

    override public init() {
        super.init()
        
        self.size.height = UITableViewAutomaticDimension
    }

    func getRenderer() -> UITableViewCell? {
        fatalError("")
    }

    func setRendererView(renderer: UITableViewCell?) {

    }

    public func didSelect() {

    }

    public func accessoryButtonTapped() {
        
    }

    public func append(newElement: TableRowElement, offset: Int = 1) {

        self.section?.insert(newElement, atIndex: self.index.1 + offset)
    }

    public func remove() {

        self.section?.remove(self)
    }

    public func replace(to: (@autoclosure () -> TableRowElement)? = nil) {

        self.section?.replace(self, to: to)
    }
}

public class TableRowRendererElement<T: UITableViewCell where T: TableElementRendererProtocol>: TableRowElement, RendererProtocol {

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


    override func getRenderer() -> UITableViewCell? {
        return self.renderer
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
extension UITableViewCell {

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

    public class StyleDefault: UITableViewCell, TableElementRendererProtocol {

        public class var identifier: String {
            return "UITableViewCell.StyleDefault"
        }

        public class var canRegister: Bool {
            return true
        }

        public class func register(tableView: UITableView) {

            tableView.registerClass(self, forCellReuseIdentifier: self.identifier)
        }
    }

    public class StyleValue1: UITableViewCell, TableElementRendererProtocol {

        public class var identifier: String {
            return "UITableViewCell.StyleValue1"
        }

        public class var canRegister: Bool {
            return true
        }

        public class func register(tableView: UITableView) {

            tableView.registerClass(self, forCellReuseIdentifier: self.identifier)
        }

        override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        }

        required public init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }

    public class StyleValue2: UITableViewCell, TableElementRendererProtocol {

        public class var identifier: String {
            return "UITableViewCell.StyleValue2"
        }

        public class var canRegister: Bool {
            return true
        }

        public class func register(tableView: UITableView) {

            tableView.registerClass(self, forCellReuseIdentifier: self.identifier)
        }

        override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .Value2, reuseIdentifier: reuseIdentifier)
        }

        required public init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }

    public class StyleSubtitle: UITableViewCell, TableElementRendererProtocol {

        public class var identifier: String {
            return "UITableViewCell.StyleSubtitle"
        }

        public class var canRegister: Bool {
            return true
        }

        public class func register(tableView: UITableView) {

            tableView.registerClass(self, forCellReuseIdentifier: self.identifier)
        }

        override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        }

        required public init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
}

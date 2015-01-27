//
//  TableRowElement.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/11.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit

public class TableRowBase: LayoutElement {

    /// section, row
    var index: (Int?, Int?) {

        if let s = self.section {

            let section = s.index
            if let index = find(s.rows, self) {
                return (section, index)
            }
            return (section, nil)
        }
        return (nil, nil)
    }

    public var accessoryType: UITableViewCellAccessoryType = .None
    public var selectionStyle: UITableViewCellSelectionStyle = .Default
    public var separatorStyle: UITableViewCellSeparatorStyle = .SingleLine // SingleLineEtched is not supported
    public var separatorInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    public var selected: Bool = false

    weak var section: TableSection?

    class func register(tableView: UITableView) {
        fatalError("")
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

    public func nextResponder() -> UIResponder? {
        return self.section?.nextResponder()
    }

    public func didSelect() {
        self.selected = false
    }

    public func accessoryButtonTapped() {
        
    }

    public func append(newElement: TableRowBase) {

        self.section?.insert(newElement, atIndex: self.index.1! + 1)
    }

    public func remove() {

        self.section?.remove(self)
    }

    public func replace(to: (@autoclosure () -> TableRowBase)? = nil) {

        self.section?.replace(self, to: to)
    }

    public func willMoveToRenderer(view: UITableViewCell?) {

    }
}

public class TableRow<T: UITableViewCell where T: TableElementRendererProtocol>: TableRowBase, RendererProtocol {

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

    override public var size: CGSize {
        didSet {
            self.replace()
        }
    }

    public var renderer: Renderer? {

        didSet {
            if oldValue != self.renderer {
                oldValue?.rowElement?.viewDidDisappear()
            }

            if self.renderer != nil {
                self.viewWillAppear()
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

    var rowElement: TableRowBase? {

        get {
            let val: AnyObject! = objc_getAssociatedObject(self, &UITableViewCell_rowElement)

            return val as? TableRowBase
        }

        set {
            if let newValue = newValue {
                newValue.willMoveToRenderer(self)
            } else {
                self.rowElement?.willMoveToRenderer(nil)
            }
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

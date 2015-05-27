//
//  TableRowElement.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/11.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit

public class TableRowBase: LayoutElement, Equatable {

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
    
    public var indexPath: NSIndexPath? {
        let idx = self.index
        if let section = idx.0, row = idx.1 {
            return NSIndexPath(forRow: row, inSection: section)
        }
        return nil
    }

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
    
    public func hasFirstResponder() -> Bool {
    
        if let v = self.getRenderer() {
            return self.findFirstResponder(v)
        }
        return false
    }
    
    private func findFirstResponder(view: UIView) -> Bool {
        
        if view.isFirstResponder() {
            return true
        }
        for v in view.subviews as! [UIView] {
            return findFirstResponder(v)
        }
        return false
    }
    
    public func scroll(#to: UITableViewScrollPosition, animated: Bool = true) -> Bool {
        
        if let tableView = self.section?.controller?.tableView,
            let indexPath = self.indexPath
        {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: to, animated: animated)
            return true
        }
        return false
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

    public func replace() {
        
        self.replace(to: nil)
    }
    
    public func replace(@autoclosure(escaping) #to: () -> TableRowBase?) {

        self.section?.replace(self, to: to)
    }

    public func willMoveToRenderer(view: UITableViewCell?) {

    }
}

public func == (lhs: TableRowBase, rhs: TableRowBase) -> Bool {
    return lhs === rhs
}

public protocol TableRowProtocol {
    
//    typealias Renderer: UITableViewCell, TableElementRendererProtocol
//    
//    var size: CGSize { get set }
//    var renderer: Renderer? { get }
}

public class TableRow<T: UITableViewCell where T: TableElementRendererProtocol>: TableRowBase, RendererProtocol, TableRowProtocol {

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
            if self.size.height != oldValue.height {
                self.replace()
            }
        }
    }

    public weak var renderer: Renderer? {

        willSet {
            if newValue != self.renderer {
                self.renderer?.rowElement?.viewWillDisappear()
            }
        }

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


private class DefaultTableRow<T: UITableViewCell where T: TableElementRendererProtocol>: TableRow<T>, TableRowProtocol {
    
    var text: String! {
        willSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.renderer?.textLabel?.text = newValue
            }
        }
    }
    var detailText: String! {
        willSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.renderer?.detailTextLabel?.text = newValue
            }
        }
    }
    
    init(text: String!, detailText: String! = nil) {
        self.text = text
        self.detailText = detailText
        super.init()
    }
    
    private override func viewWillAppear() {
        super.viewWillAppear()
        
        self.renderer?.textLabel?.text = self.text
        self.renderer?.detailTextLabel?.text = self.detailText
    }
}

extension UITableView {
    
    public class func StyleDefaultRow(#text: String!) -> TableRow<UITableViewCell.StyleDefault> {
        return DefaultTableRow<UITableViewCell.StyleDefault>(text: text, detailText: nil)
    }
    public class func StyleValue1Row(#text: String!, detailText: String! = nil) -> TableRow<UITableViewCell.StyleValue1> {
        return DefaultTableRow<UITableViewCell.StyleValue1>(text: text, detailText: detailText)
    }
    public class func StyleValue2Row(#text: String!, detailText: String! = nil) -> TableRow<UITableViewCell.StyleValue2> {
        return DefaultTableRow<UITableViewCell.StyleValue2>(text: text, detailText: detailText)
    }
    public class func StyleSubtitleRow(#text: String!, detailText: String! = nil) -> TableRow<UITableViewCell.StyleSubtitle> {
        return DefaultTableRow<UITableViewCell.StyleSubtitle>(text: text, detailText: detailText)
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

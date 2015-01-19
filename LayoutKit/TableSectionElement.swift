//
//  TableSectionElement.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/11.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit

public class TableSection: NSObject {

    public private(set) var rows: [TableRowElement] = []
    var index: Int {
        return find(self.controller!.sections, self)!
    }

    var transactionCache: [(UITableView?) -> Void] = []

    weak var controller: TableController? {
        didSet {
            self.popTransaction(self.controller?.tableView)
        }
    }

    public var header: TableSectionElement? {
        willSet {
            newValue?.sectionType = .Header
        }
    }
    public var footer: TableSectionElement? {
        willSet {
            newValue?.sectionType = .Footer
        }
    }
    public func append(newElement: TableRowElement) {

        self.insert(newElement, atIndex: NSNotFound)
    }

    public func insert(newElement: TableRowElement, atIndex index: Int) {

        let index = index == self.rows.count ? NSNotFound : index

        let block: TableController.Processor = {
            let index = index == NSNotFound ? self.rows.count : index
            let indexes = NSIndexSet(index: index)

            let list: TableController.ListProcess = {
                self.rows.insert(newElement, atIndex: index)
                newElement.section = self
            }
            let ui: TableController.UIProcess = { (tableView) in
                self.updateRowContent(kind: .Insertion, indexes: indexes)
            }

            return (list, ui)
        }

        if let c = self.controller {
            c.transaction.append(block, .Insertion)
        } else {
            let (list, _) = block()
            list()
        }
    }

    public func extend(newElements: [TableRowElement]) {

        for e in newElements {
            self.append(e)
        }
    }

    func removeAtIndex(index: Int) {

        let indexes = NSIndexSet(index: index)
        self.updateRowContent(kind: .Removal, indexes: indexes)
    }

    public func removeAll() {

        for i in reverse(0..<self.rows.count) {
            self.removeAtIndex(i)
        }
    }

    public func removeLast() {

        self.removeAtIndex(self.rows.count - 1)
    }

    func replaceAtIndex(index: Int, to: (@autoclosure () -> TableRowElement)? = nil) {

        func inlineRefresh() {

            self.transactionCache.append({ (tableView: UITableView?) -> Void in
                if let t = tableView {
                    t.beginUpdates()
                    t.endUpdates()
                }
            })

            if let c = self.controller {
                self.popTransaction(c.tableView)
            }
        }
        func outlineRefresh(row: TableRowElement) {

            let indexes = NSIndexSet(index: index)
            self.updateRowContent(kind: .Replacement, indexes: indexes)
        }
        if let row = to?() {
            let old = self.rows[index]
            if row == old {
                inlineRefresh()
            } else {
                outlineRefresh(row)
            }
        } else {
            inlineRefresh()
        }
    }

    public func remove(row: TableRowElement) {

        if let index = find(self.rows, row) {
            self.removeAtIndex(index)
        }
    }

    public func replace(row: TableRowElement, to: (@autoclosure () -> TableRowElement)? = nil) {

        if let index = find(self.rows, row) {
            self.replaceAtIndex(index, to: to)
        }
    }

    func updateRowContent(#kind: NSKeyValueChange, indexes: NSIndexSet) {

        if let t = self.controller?.tableView {

            var indexPaths: [NSIndexPath] = []
            indexes.enumerateIndexesUsingBlock({ (i, stop) -> Void in
                let indexPath = NSIndexPath(forRow: i, inSection: self.index)
                indexPaths.append(indexPath)
            })


            switch kind {
            case .Setting:
                break
            case .Insertion:
                t.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
            case .Replacement:
                t.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
            case .Removal:
                t.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
            }
        }
    }

    func popTransaction(tableView: UITableView?) {

        for t in reverse(self.transactionCache) {
            t(tableView)
        }
        self.transactionCache.removeAll(keepCapacity: true)
    }
}
public typealias BlankSection = TableSection

enum SectionType {
    case Header
    case Footer
}

public class TableSectionElement: LayoutElement {

    override class var identifier: String {
        return ""
    }

    class func register(tableView: UITableView) {

    }

    var sectionType: SectionType! {

        willSet {

            if self.sectionType != nil {
                if newValue != self.sectionType {
                    self.viewWillDisappear()
                }
            }
        }

        didSet {

            if oldValue != nil {
                if oldValue != self.sectionType {
                    self.viewDidDisappear()
                }
            }
        }
    }


    override public init() {
        super.init()
    }

    func setRendererView(renderer: UITableViewHeaderFooterView?) {

    }
}

public class TableSectionRendererElement<T: UITableViewHeaderFooterView>: TableSectionElement, RendererProtocol {

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
            switch self.sectionType! {
            case .Header:
                newValue?.sectionHeaderElement?.viewWillAppear()
            case .Footer:
                newValue?.sectionFooterElement?.viewWillAppear()
            }
        }

        didSet {
            if oldValue != self.renderer {
                switch self.sectionType! {
                case .Header:
                    oldValue?.sectionHeaderElement?.viewDidDisappear()
                case .Footer:
                    oldValue?.sectionFooterElement?.viewDidDisappear()
                }
            }

            if self.renderer != nil {
                self.viewDidAppear()
            }
        }
    }

    override public init() {
        super.init()
    }

    override func setRendererView(renderer: UITableViewHeaderFooterView?) {

        if let renderer = renderer {
            self.renderer = renderer as? Renderer
        } else {
            self.renderer = nil
        }
    }
}


private var UITableViewHeaderFooterView_sectionHeaderElement: UInt8 = 0
private var UITableViewHeaderFooterView_sectionFooterElement: UInt8 = 0
extension UITableViewHeaderFooterView: TableElementRendererProtocol {

    public class var identifier: String {
        return "UITableViewHeaderFooterView"
    }

    public class var canRegister: Bool {
        return true
    }

    public class func register(tableView: UITableView) {

        tableView.registerClass(self, forHeaderFooterViewReuseIdentifier: self.identifier)
    }

    var sectionHeaderElement: TableSectionElement? {

        get {
            let val: AnyObject! = objc_getAssociatedObject(self, &UITableViewHeaderFooterView_sectionHeaderElement)

            return val as? TableSectionElement
        }

        set {
            objc_setAssociatedObject(self, &UITableViewHeaderFooterView_sectionHeaderElement, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }

    var sectionFooterElement: TableSectionElement? {

        get {
            let val: AnyObject! = objc_getAssociatedObject(self, &UITableViewHeaderFooterView_sectionHeaderElement)

            return val as? TableSectionElement
        }

        set {
            objc_setAssociatedObject(self, &UITableViewHeaderFooterView_sectionHeaderElement, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
}

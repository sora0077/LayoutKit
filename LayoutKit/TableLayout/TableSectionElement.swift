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
    private var displayedRows: [TableRowElement] = []

    var index: Int {
        return find(self.controller!.sections, self)!
    }

    var transactionCache: [(UITableView?) -> Void] = []

    weak var controller: TableController?

    public var header: TableSectionElement? {
        willSet {
            newValue?.sectionType = .Header
            newValue?.section = self
        }
    }
    public var footer: TableSectionElement? {
        willSet {
            newValue?.sectionType = .Footer
            newValue?.section = self
        }
    }

    public func nextResponder() -> UIResponder? {
        return self.controller?.responder
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
            c.transaction.append(block, .Insertion, index)
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

        let block: TableController.Processor = {
            let index = index == NSNotFound ? self.rows.count - 1 : index
            let indexes = NSIndexSet(index: index)

            let list: TableController.ListProcess = {
                self.rows.removeAtIndex(index); return
            }
            let ui: TableController.UIProcess = { (tableView) in
                self.updateRowContent(kind: .Removal, indexes: indexes)
            }

            return (list, ui)
        }

        if let c = self.controller {
            c.transaction.append(block, .Removal, index)
        } else {
            let (list, _) = block()
            list()
        }
    }

    public func removeAll() {

        for i in reverse(0..<self.rows.count) {
            self.removeAtIndex(i)
        }
    }

    public func removeLast() {

        self.removeAtIndex(NSNotFound)
    }

    func replaceAtIndex(index: Int, to: (@autoclosure () -> TableRowElement)? = nil) {

        func inlineRefresh() {

            if let c = self.controller {
                let list: TableController.ListProcess = {}
                let ui: TableController.UIProcess = { (_) in }
                c.transaction.append({ (list, ui) }, .Replacement, index)
            }
        }
        func outlineRefresh(row: TableRowElement, old: TableRowElement) {

            let block: TableController.Processor = {
                if let index = find(self.rows, old) {
                    let indexes = NSIndexSet(index: index)

                    let list: TableController.ListProcess = {
                        self.rows[index] = row
                    }
                    let ui: TableController.UIProcess = { (tableView) in
                        self.updateRowContent(kind: .Replacement, indexes: indexes)
                    }

                    return (list, ui)
                }

                return ({}, { (_) in })
            }

            if let c = self.controller {
                c.transaction.append(block, .Replacement, index)
            } else {
                let (list, _) = block()
                list()
            }
        }
        if let row = to?() {
            let old = self.rows[index]
            if row == old {
                inlineRefresh()
            } else {
                outlineRefresh(row, old)
            }
        } else {
            inlineRefresh()
        }
    }

    public func remove(row: TableRowElement) {

        let initialIndex = find(self.rows, row)
        if initialIndex == nil {
            return
        }
        
        let block: TableController.Processor = {
            if let index = find(self.rows, row) {
                let indexes = NSIndexSet(index: index)

                let list: TableController.ListProcess = {
                    self.rows.removeAtIndex(index); return
                }
                let ui: TableController.UIProcess = { (tableView) in
                    self.updateRowContent(kind: .Removal, indexes: indexes)
                }
                
                return (list, ui)
            }
            return ({}, { (_) in })
        }

        if let c = self.controller {
            c.transaction.append(block, .Removal, initialIndex!)
        } else {
            let (list, _) = block()
            list()
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

}
//public typealias BlankSection = TableSection

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

    weak var section: TableSection?

    override public init() {
        super.init()
    }

    func setRendererView(renderer: UITableViewHeaderFooterView?) {

    }

    public func nextResponder() -> UIResponder? {
        return self.section?.nextResponder()
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

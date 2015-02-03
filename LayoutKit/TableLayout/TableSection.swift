//
//  TableSectionElement.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/11.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit

public class TableSection: NSObject {

    public private(set) var rows: [TableRowBase] = []
    private var displayedRows: [TableRowBase] = []

    var index: Int? {
        return find(self.controller!.sections, self)
    }

    var transactionCache: [(UITableView?) -> Void] = []

    weak var controller: TableController?

    public var header: TableHeaderFooterBase? {
        willSet {
            newValue?.sectionType = .Header
            newValue?.section = self
        }
    }
    public var footer: TableHeaderFooterBase? {
        willSet {
            newValue?.sectionType = .Footer
            newValue?.section = self
        }
    }

    public func nextResponder() -> UIResponder? {
        return self.controller?.responder
    }

    public func append(newElement: TableRowBase) {

        self.insert(newElement, atIndex: self.rows.count)
    }

    public func insert(newElement: TableRowBase, atIndex index: @autoclosure () -> Int) {

        let block: TableController.Processor = {
            let index = index()
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
            c.addTransaction((block, .Insertion, index()))
        } else {
            let (list, _) = block()
            list()
        }
    }

    public func extend(newElements: [TableRowBase]) {

        for e in newElements {
            self.append(e)
        }
    }

    func removeAtIndex(index: @autoclosure () -> Int) {

        let block: TableController.Processor = {
            let index = index()
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
            c.addTransaction((block, .Removal, index()))
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

        self.removeAtIndex(self.rows.count - 1)
    }

    func replaceAtIndex(index: Int, to: (@autoclosure () -> TableRowBase)? = nil) {

        func inlineRefresh() {

            if let c = self.controller {
                let list: TableController.ListProcess = {}
                let ui: TableController.UIProcess = { (_) in }
                c.addTransaction(({ (list, ui) }, .Replacement, index))
            }
        }
        func outlineRefresh(row: TableRowBase, old: TableRowBase) {

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
                c.addTransaction((block, .Replacement, index))
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

    public func remove(row: TableRowBase) {

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
            c.addTransaction((block, .Removal, initialIndex!))
        } else {
            let (list, _) = block()
            list()
        }
    }

    public func replace(row: TableRowBase, to: (@autoclosure () -> TableRowBase)? = nil) {

        if let index = find(self.rows, row) {
            self.replaceAtIndex(index, to: to)
        }
    }

    func updateRowContent(#kind: NSKeyValueChange, indexes: NSIndexSet) {

        if let t = self.controller?.tableView {

            var indexPaths: [NSIndexPath] = []
            indexes.enumerateIndexesUsingBlock({ (i, stop) -> Void in
                let indexPath = NSIndexPath(forRow: i, inSection: self.index!)
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

public class TableHeaderFooterBase: LayoutElement {

    override class var identifier: String {
        return ""
    }

    class func register(tableView: UITableView) {

    }

    var sectionType: SectionType! {

        didSet {

            if oldValue != nil {
                if oldValue != self.sectionType {
                    self.viewDidDisappear()
                }
            }
        }
    }

    override public var size: CGSize {
        didSet {
            if oldValue.height != self.size.height {
                if let s = self.section {
                    if let i = s.index {
                        s.controller?.replaceAtIndex(i, to: nil)
                    }
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

public class TableHeaderFooter<T: UITableViewHeaderFooterView>: TableHeaderFooterBase, RendererProtocol {

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

        didSet {
            if let renderer = self.renderer {
                switch self.sectionType! {
                case .Header:
                    renderer.sectionHeaderElement?.viewWillAppear()
                case .Footer:
                    renderer.sectionFooterElement?.viewWillAppear()
                }
            }

            if oldValue != self.renderer {
                switch self.sectionType! {
                case .Header:
                    oldValue?.sectionHeaderElement?.viewDidDisappear()
                case .Footer:
                    oldValue?.sectionFooterElement?.viewDidDisappear()
                }
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

    var sectionHeaderElement: TableHeaderFooterBase? {

        get {
            let val: AnyObject! = objc_getAssociatedObject(self, &UITableViewHeaderFooterView_sectionHeaderElement)

            return val as? TableHeaderFooterBase
        }

        set {
            objc_setAssociatedObject(self, &UITableViewHeaderFooterView_sectionHeaderElement, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }

    var sectionFooterElement: TableHeaderFooterBase? {

        get {
            let val: AnyObject! = objc_getAssociatedObject(self, &UITableViewHeaderFooterView_sectionHeaderElement)

            return val as? TableHeaderFooterBase
        }

        set {
            objc_setAssociatedObject(self, &UITableViewHeaderFooterView_sectionHeaderElement, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
}

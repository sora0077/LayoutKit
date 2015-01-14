//
//  TableController.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/11.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit


protocol TableElementProtocol: NSObjectProtocol {

    class var identifier: String { get }
    class var canRegister: Bool { get }

    class func register(tableView: UITableView)
    
}

public protocol TableElementRendererProtocol {

    class var identifier: String { get }
    class var canRegister: Bool { get }
    class func register(tableView: UITableView)
}

public final class TableController: NSObject {

    public private(set) var sections: [TableSection] = []

    weak var tableView: UITableView?


    private var registeredCells: [String: Bool] = [:]
    private var registeredHeaderFooterViews: [String: Bool] = [:]


    weak var altDelegate: UITableViewDelegate?
    weak var altDataSource: UITableViewDataSource?

    override public init() {
        super.init()
        let section = BlankSection()
        section.controller = self
        self.sections = [section]
    }

    public subscript(index: Int) -> TableSection {

        get {
            return self.sections[index]
        }
        set {
            self.insert(newValue, atIndex: index)
        }
    }

    public func append(newElement: TableSection) {

        self.insert(newElement, atIndex: self.sections.count)
    }

    public func insert(newElement: TableSection, atIndex index: Int) {

        let indexes = NSIndexSet(index: index)
        self.sections.insert(newElement, atIndex: index)
        self.updateSectionContent(kind: .Insertion, indexes: indexes)
        newElement.controller = self
    }

    public func extend(newElements: [TableSection]) {

        for e in newElements {
            self.append(e)
        }
    }

    func removeAtIndex(index: Int) {

        let indexes = NSIndexSet(index: index)
        self.sections.removeAtIndex(index)
        self.updateSectionContent(kind: .Removal, indexes: indexes)
    }

    public func removeAll() {

        for i in reverse(0..<self.sections.count) {
            self.removeAtIndex(i)
        }
    }

    public func removeLast() {

        self.removeAtIndex(self.sections.count - 1)
    }

    func replaceAtIndex(index: Int, to: (@autoclosure () -> TableSection)? = nil) {

        func inlineRefresh() {

            if let t = self.tableView {
                t.beginUpdates()
                t.endUpdates()
            }
        }
        func outlineRefresh(section: TableSection) {

            section.controller = self
            self.sections[index] = section
            let indexes = NSIndexSet(index: index)

            self.updateSectionContent(kind: .Replacement, indexes: indexes)
        }
        if let section = to?() {
            let old = self.sections[index]
            if section == old {
                inlineRefresh()
            } else {
                outlineRefresh(section)
            }
        } else {
            inlineRefresh()
        }
    }

    public func remove(section: TableSection) {

        if let index = find(self.sections, section) {
            self.removeAtIndex(index)
        }
    }
    

    func updateSectionContent(#kind: NSKeyValueChange, indexes: NSIndexSet) {

        if let t = self.tableView {

            t.beginUpdates()

            switch kind {
            case .Setting:
                break
            case .Insertion:
                t.insertSections(indexes, withRowAnimation: .Automatic)
            case .Replacement:
                break
            case .Removal:
                break
            }

            t.endUpdates()
        }
    }
}

extension TableController {

    func attachTableView(tableView: UITableView) {
        self.tableView = tableView

        self.altDelegate = tableView.delegate
        self.altDataSource = tableView.dataSource

        tableView.delegate = self
        tableView.dataSource = self
    }

    func detachTableView(tableView: UITableView) {

        self.registeredCells.removeAll(keepCapacity: true)
        self.registeredHeaderFooterViews.removeAll(keepCapacity: true)

        tableView.delegate = self.altDelegate
        tableView.dataSource = self.altDataSource

        self.tableView = nil
    }

    private func rows(indexPath: NSIndexPath) -> TableRowElement {

        let s = self.sections[indexPath.section]
        let r = s.rows[indexPath.row]
        return r
    }
}

//MARK: Table Setting
extension TableController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return self.sections.count
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let s = self.sections[section]
        return s.rows.count
    }
}

//MARK: Cell
extension TableController {

    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        let r = self.rows(indexPath)
        return r.estimatedSize.height
    }

    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        let r = self.rows(indexPath)
        return r.size.height
    }

    private typealias DequeueFunc = (String, forIndexPath: NSIndexPath) -> AnyObject
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let r = self.rows(indexPath)
        let clazz = r.dynamicType

        let identifier = clazz.identifier
        let is_registered = self.registeredCells[identifier] ?? false
        if !is_registered && clazz.canRegister {
            clazz.register(tableView)
            self.registeredCells[identifier] = true
        }

        let dequeue: DequeueFunc = tableView.dequeueReusableCellWithIdentifier
        let cell = dequeue(identifier, forIndexPath: indexPath) as UITableViewCell
        cell.rowElement = r
        cell.accessoryType = r.accessoryType
        cell.selectionStyle = r.selectionStyle

        return cell
    }

    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if let r = cell.rowElement {
            r.setRendererView(cell)
        }
    }

    public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if let r = cell.rowElement {
            r.setRendererView(nil)
        }
        cell.rowElement = nil
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let r = self.rows(indexPath)
        if r.autoDeselect {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        r.didSelect()
    }

    public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {

        let r = self.rows(indexPath)
        r.accessoryButtonTapped()
    }
}

//MARK: Header
extension TableController {

    public func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        let s = self.sections[section]
        return s.header?.estimatedSize.height ?? UITableViewAutomaticDimension
    }

    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        let s = self.sections[section]
        return s.header?.size.height ?? UITableViewAutomaticDimension
    }

    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if let s = self.sections[section].header {
            let clazz = s.dynamicType
            let identifier = clazz.identifier
            let is_registered = self.registeredHeaderFooterViews[identifier] ?? false

            if identifier.isEmpty {
                return nil
            }

            if !is_registered && clazz.canRegister {
                clazz.register(tableView)
                self.registeredHeaderFooterViews[identifier] = true
            }

            let dequeue = tableView.dequeueReusableHeaderFooterViewWithIdentifier
            let cell = dequeue(identifier) as? UITableViewHeaderFooterView
            if let f = cell?.sectionFooterElement {
                f.setRendererView(nil)
                cell?.sectionFooterElement = nil
            }
            cell?.sectionHeaderElement = s

            return cell
        }
        return nil
    }

    public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        if let view = view as? UITableViewHeaderFooterView {
            view.sectionHeaderElement?.setRendererView(view)
        }
    }

    public func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {

        if let view = view as? UITableViewHeaderFooterView {
            if let s = view.sectionHeaderElement {
                s.setRendererView(nil)
            }
            view.sectionHeaderElement = nil
        }
    }
}

//MARK: Footer
extension TableController {

    public func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {

        let s = self.sections[section]
        return s.footer?.estimatedSize.height ?? UITableViewAutomaticDimension
    }

    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        let s = self.sections[section]
        return s.footer?.size.height ?? UITableViewAutomaticDimension
    }

    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        if let s = self.sections[section].footer {
            let clazz = s.dynamicType
            let identifier = clazz.identifier
            let is_registered = self.registeredHeaderFooterViews[identifier] ?? false

            if identifier.isEmpty {
                return nil
            }

            if !is_registered && clazz.canRegister {
                clazz.register(tableView)
                self.registeredHeaderFooterViews[identifier] = true
            }

            let dequeue = tableView.dequeueReusableHeaderFooterViewWithIdentifier
            let cell = dequeue(identifier) as? UITableViewHeaderFooterView
            if let f = cell?.sectionHeaderElement {
                f.setRendererView(nil)
                cell?.sectionHeaderElement = nil
            }
            cell?.sectionFooterElement = s
        }
        return nil
    }

    public func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {

        if let view = view as? UITableViewHeaderFooterView {
            view.sectionFooterElement?.setRendererView(view)
        }
    }

    public func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {

        if let view = view as? UITableViewHeaderFooterView {
            if let s = view.sectionFooterElement {
                s.setRendererView(nil)
            }
            view.sectionFooterElement = nil
        }
    }
}


private var UITableView_controller: UInt8 = 0
extension UITableView {

    public var controller: TableController? {

        get {
            return objc_getAssociatedObject(self, &UITableView_controller) as? TableController
        }

        set {
            self.controller?.detachTableView(self)
            if self.controller != newValue {
                if let c = newValue {
                    c.attachTableView(self)
                }
            }

            objc_setAssociatedObject(self, &UITableView_controller, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
}


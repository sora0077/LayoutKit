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

protocol TableElementRendererClass {

    class var identifier: String { get }
    class var canRegister: Bool { get }
    class func register(tableView: UITableView)
}

public final class TableController: NSObject {

    var sections: [TableSection] = []

    weak var tableView: UITableView?


    private var registeredCells: [String: Bool] = [:]
    private var registeredHeaderFooterViews: [String: Bool] = [:]


    private weak var altDelegate: UITableViewDelegate?
    private weak var altDataSource: UITableViewDataSource?

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

        self.sections.append(newElement)
        let indexes = NSIndexSet(index: self.sections.count)
        self.updateSectionContent(kind: .Insertion, indexes: indexes)

        newElement.controller = self
    }

    public func insert(newElement: TableSection, atIndex index: Int) {

        self.sections.insert(newElement, atIndex: index)
    }

    public func extend(newElements: [TableSection]) {

        self.sections.extend(newElements)
    }

    public func removeAtIndex(index: Int) {

        self.sections.removeAtIndex(index)
    }

    public func removeAll() {

        self.sections.removeAll(keepCapacity: true)
    }

    public func removeLast() {
        
        self.sections.removeLast()
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
        s.index = section
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

        r.index = (indexPath.section, indexPath.row)
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
            if self.controller != newValue {
                if let c = newValue {
                    c.attachTableView(self)
                } else {
                    self.controller?.detachTableView(self)
                }
            }

            objc_setAssociatedObject(self, &UITableView_controller, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
}


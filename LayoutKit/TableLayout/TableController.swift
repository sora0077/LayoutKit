//
//  TableController.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/11.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit


private func async_main_safe(block: () -> Void) {
    
    if NSThread.isMainThread() {
        block()
    } else {
        dispatch_async(dispatch_get_main_queue(), block)
    }
}

protocol TableElementProtocol: NSObjectProtocol {

    static var identifier: String { get }
    static var canRegister: Bool { get }

    static func register(tableView: UITableView)
    
}

public protocol TableElementRendererProtocol {

    static var identifier: String { get }
    static var canRegister: Bool { get }
    static func register(tableView: UITableView)
}

/**
*  <#Description#>
*/
public final class TableController: NSObject {

    typealias ListProcess = () -> Void
    typealias UIProcess = (tableView: UITableView?) -> Void
    typealias Processor = () -> (ListProcess, UIProcess)

    enum ElementType {
        case Section
        case Row
    }

    public private(set) var sections: [TableSection] = []

    public internal(set) weak var tableView: UITableView?


    var registeredCells: [String: Bool] = [:]
    var registeredHeaderFooterViews: [String: Bool] = [:]

    var displayLink: CADisplayLink?

    var transaction: [(Processor, NSKeyValueChange, Int)] = []
    weak var altDelegate: UITableViewDelegate?
    weak var altDataSource: UITableViewDataSource?

    weak var responder: UIResponder?

    private var updating: Bool = false

    private var animating: Bool = true


    public required init(responder: UIResponder?, sections: [TableSection]) {
        self.responder = responder
        
        super.init()

        for section in sections {
            section.controller = self
        }
        self.sections = sections
    }
    
    /**
    :param: responder <#responder description#>
    :param: section   <#section description#>
    */
    public convenience init(responder: UIResponder?, section: TableSection = TableSection()) {
        self.init(responder: responder, sections: [section])
    }

    deinit {

    }
}

extension TableController {

    
    func updateWithoutAnimate() {

        if self.transaction.count > 0 {
            for t in self.transaction {
                let (list, _) = t.0()
                list()
            }
            self.tableView?.reloadData()
            self.transaction.removeAll(keepCapacity: true)
        }

        self.displayLink?.invalidate()
        self.displayLink = nil
        self.animating = true
        self.updating = false
    }
    
    func updateWithAnimate() {
        
        typealias Operation = (() -> Void, Int)

        if self.transaction.count > 0 && self.updating == false {
            self.updating = true

            let transaction = self.transaction[0]
            var kind = transaction.1
            var operations: [Operation] = []

            let num = self.transaction.count

            if num > 16 {
                self.updateWithoutAnimate()
                return
            }
            self.tableView?.beginUpdates()

            //一度で大量に処理されることを防ぐ
            for _ in 0..<min(num, 16) {
                let vv = self.transaction.removeAtIndex(0)

                if vv.1 != kind {
                    let stream: [Operation]
                    if kind == .Removal {
                        stream = sorted(operations) { $0.1 > $1.1 }
                    } else {
                        stream = operations
                    }
                    for vv in stream {
                        vv.0()
                    }
                    operations.removeAll(keepCapacity: true)

                    self.tableView?.endUpdates()
                    self.tableView?.beginUpdates()
                }

                let operation: Operation = ({
                    let (list, ui) = vv.0()
                    list()
                    ui(tableView: self.tableView)
                }, vv.2)
                operations.append(operation)

                kind = vv.1
            }
            let stream: [Operation]
            if kind == .Removal {
                stream = sorted(operations) { $0.1 > $1.1 }
            } else {
                stream = operations
            }
            for vv in stream {
                vv.0()
            }
            self.tableView?.endUpdates()

            if self.transaction.count > 0 {
                self.animating = false
            } else {
                self.displayLink?.invalidate()
                self.displayLink = nil
            }
            
            self.updating = false
        }
    }

    @objc
    func update() {

        if self.animating {
            self.updateWithAnimate()
        } else {
            self.updateWithoutAnimate()
        }
    }

    func addTransaction(t: (Processor, NSKeyValueChange, Int)) {

        async_main_safe {
            if self.displayLink == nil {
                self.displayLink = CADisplayLink(target: self, selector: "update")
                self.displayLink?.frameInterval = 20
                self.displayLink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
            }
            self.transaction.append(t)
        }
    }
    
    public func invalidate() {
    
        async_main_safe {
            self.updateWithoutAnimate()
        }
    }
}

extension TableController {

    public func append(newElement: TableSection) {

        self.insert(newElement, atIndex: self.sections.count)
    }

    public func insert(newElement: TableSection, @autoclosure(escaping) atIndex index: () -> Int) {

        let block: Processor = {
            let index = index()
            let indexes = NSIndexSet(index: index)

            let list: ListProcess = {
                self.sections.insert(newElement, atIndex: index)
                newElement.controller = self
            }
            let ui: UIProcess = { (tableView) in
                self.updateSectionContent(kind: .Insertion, indexes: indexes)
            }

            return (list, ui)
        }
        self.addTransaction((block, .Insertion, index()))
    }

    public func extend(newElements: [TableSection]) {

        for e in newElements {
            self.append(e)
        }
    }

    func removeAtIndex(@autoclosure(escaping) index: () -> Int) {

        let block: Processor = {
            let index = index()
            let indexes = NSIndexSet(index: index)

            let list: ListProcess = {
                self.sections.removeAtIndex(index); return
            }
            let ui: UIProcess = { (tableView) in
                self.updateSectionContent(kind: .Removal, indexes: indexes)
            }
            return (list, ui)
        }
        self.addTransaction((block, .Removal, index()))
    }

    public func removeAll() {

        for i in reverse(0..<self.sections.count) {
            self.removeAtIndex(i)
        }
    }

    public func removeLast() {

        self.removeAtIndex(self.sections.count - 1)
    }
    
    func replaceAtIndex(index: Int) {
        self.replaceAtIndex(index, to: nil)
    }

    func replaceAtIndex(index: Int, @autoclosure(escaping) to: () -> TableSection?) {

        func inlineRefresh() {

            println("replace inline ", index)
            let indexes = NSIndexSet(index: index)
            let list: TableController.ListProcess = {}
            let ui: TableController.UIProcess = { (tableView) in
                self.updateSectionContent(kind: .Replacement, indexes: indexes)
            }
            self.addTransaction(({ (list, ui) }, .Replacement, index))
        }
        func outlineRefresh(section: TableSection, old: TableSection) {

            let block: TableController.Processor = {
                if let index = find(self.sections, old) {
                    let indexes = NSIndexSet(index: index)

                    let list: TableController.ListProcess = {
                        self.sections[index] = section
                    }
                    let ui: TableController.UIProcess = { (tableView) in
                        self.updateSectionContent(kind: .Replacement, indexes: indexes)
                    }

                    return (list, ui)
                }

                return ({}, { (_) in })
            }

            self.addTransaction((block, .Replacement, index))
        }
        if let section = to() {
            let old = self.sections[index]
            if section == old {
                inlineRefresh()
            } else {
                outlineRefresh(section, old)
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

            switch kind {
            case .Setting:
                break
            case .Insertion:
                t.insertSections(indexes, withRowAnimation: .Automatic)
            case .Replacement:
                t.reloadSections(indexes, withRowAnimation: .Automatic)
            case .Removal:
                t.deleteSections(indexes, withRowAnimation: .Automatic)
            }
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

    private func rows(indexPath: NSIndexPath) -> TableRowBase {

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
        let cell = dequeue(identifier, forIndexPath: indexPath) as! UITableViewCell
        cell.rowElement = r
        r.setRendererView(cell)
        
        cell.accessoryType = r.accessoryType
        cell.selectionStyle = r.selectionStyle

        switch r.separatorStyle {
        case .None:
            cell.separatorInset.right = tableView.frame.width - cell.separatorInset.left
        default:
            cell.separatorInset = r.separatorInset

        }
        return cell
    }

    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if let r = cell.rowElement {
            r.viewDidLayoutSubviews()
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
        r.selected = true
        r.didSelect()

        if !r.selected {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {

        let r = self.rows(indexPath)
        r.accessoryButtonTapped()
    }
}

//MARK: Header
extension TableController {

//    public func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//
//        let s = self.sections[section]
//        return s.header?.estimatedSize.height ?? 0
//    }

    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        let s = self.sections[section]
        return s.header?.size.height ?? 0
    }

    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let s = self.sections[section]
        if let h = s.header {
            let clazz = h.dynamicType
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
            if s.footer == nil {
                if let f = cell?.sectionFooterElement {
                    f.setRendererView(nil)
                    cell?.sectionFooterElement = nil
                }
            }
            cell?.sectionHeaderElement = h

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

//    public func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
//
//        let s = self.sections[section]
//        println(("footer es \(section)", s.footer?.estimatedSize.height ?? 0))
//        return s.footer?.estimatedSize.height ?? 0
//    }

    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        let s = self.sections[section]
        return s.footer?.size.height ?? 0
    }

    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let s = self.sections[section]
        if let f = s.footer {
            let clazz = f.dynamicType
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
            if s.header == nil {
                if let h = cell?.sectionHeaderElement {
                    h.setRendererView(nil)
                    cell?.sectionHeaderElement = nil
                }
            }
            cell?.sectionFooterElement = f

            return cell
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

extension TableController: UIScrollViewDelegate {

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        self.altDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        
        self.altDelegate?.scrollViewDidZoom?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        self.altDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        self.altDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        self.altDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        
        self.altDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        self.altDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        
        self.altDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return self.altDelegate?.viewForZoomingInScrollView?(scrollView)
    }
    
    public func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView!) {
        
        self.altDelegate?.scrollViewWillBeginZooming?(scrollView, withView: view)
    }
    
    public func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
        
        self.altDelegate?.scrollViewDidEndZooming?(scrollView, withView: view, atScale: scale)
    }
    
    public func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        
        return self.altDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }
    
    public func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        
        self.altDelegate?.scrollViewDidScrollToTop?(scrollView)
    }
}


private var UITableView_controller: UInt8 = 0
extension UITableView {

    public var controller: TableController! {

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


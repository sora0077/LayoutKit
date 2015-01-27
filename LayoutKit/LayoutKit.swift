//
//  LayoutKit.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/11.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import Foundation
import CoreGraphics

protocol RendererProtocol {

//    typealias SelfType

    typealias Renderer

    var renderer: Renderer? { get }
}

protocol RendererClass {

    class var identifier: String { get }
}


public class LayoutElement: NSObject {

    public var estimatedSize: CGSize = CGSizeZero
    public var size: CGSize = CGSizeZero {
        didSet {
            self.estimatedSize = self.size
        }
    }

//    public var superelement: LayoutElement?
//    public var subelements: [LayoutElement] = []

    override public init() {
        super.init()
    }

    class var identifier: String {
        fatalError("")
    }

    class var canRegister: Bool {
        return false
    }

//    public func isViewLoaded() -> Bool {
//        fatalError("")
//    }
//
//    public func viewDidLoad() {
//
//    }

    public func viewWillAppear() {

    }

    public func viewDidDisappear() {
        
    }

    public func viewDidLayoutSubviews() {

    }


}

public class LayoutGroup: LayoutElement {

    override public init() {
        super.init()
    }

}

//
//  NormalSection.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/01/15.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit
import LayoutKit

class NormalSection<T: UITableViewHeaderFooterView>: TableHeaderFooter<T>, NormalSectionViewDelegate {

    private let title: String

    init(title: String, height: CGFloat = 40) {
        self.title = title

        super.init()

        self.size.height = height
    }

    override func viewWillAppear() {

        self.renderer?.contentView.backgroundColor = UIColor.blueColor()
//        self.renderer?.textLabel.text = self.title

        if let view = self.renderer as? NormalSectionView {
            view.delegate = self
        }
    }


    func buttonAction(view: NormalSectionView) {

        let when  = dispatch_time(DISPATCH_TIME_NOW, Int64(1))
        dispatch_after(when, dispatch_get_main_queue()) { () -> Void in

            self.size.height = 100
        }
    }
}

protocol NormalSectionViewDelegate: NSObjectProtocol {

    func buttonAction(view: NormalSectionView)
}

class NormalSectionView: UITableViewHeaderFooterView {

    weak var delegate: NormalSectionViewDelegate?

    override class var identifier: String {
        return "NormalSectionView"
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        let button = UIButton.buttonWithType(.System) as UIButton
        button.addTarget(self, action: "buttonAction", forControlEvents: .TouchUpInside)
        button.setTitle("AAA", forState: .Normal)
        button.sizeToFit()

        contentView.backgroundColor = UIColor.orangeColor()
        self.contentView.addSubview(button)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.delegate = nil
    }

    func buttonAction() {

        self.delegate?.buttonAction(self)
    }
}

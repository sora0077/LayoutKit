//
//  CollectionController.swift
//  LayoutKit
//
//  Created by 林 達也 on 2015/02/02.
//  Copyright (c) 2015年 林 達也. All rights reserved.
//

import UIKit


public class CollectionController: NSObject {

    public internal(set) weak var colllectionView: UICollectionView?

    weak var altDelegate: UICollectionViewDelegate?
    weak var altDataSource: UICollectionViewDataSource?
}

extension CollectionController: UICollectionViewDataSource {

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatalError("")
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        fatalError("")
    }
}

extension CollectionController: UICollectionViewDelegate {

}

extension CollectionController {

    func attachTableView(colllectionView: UICollectionView) {
        self.colllectionView = colllectionView

        self.altDelegate = colllectionView.delegate
        self.altDataSource = colllectionView.dataSource

        colllectionView.delegate = self
        colllectionView.dataSource = self
    }

    func detachTableView(colllectionView: UICollectionView) {

//        self.registeredCells.removeAll(keepCapacity: true)
//        self.registeredHeaderFooterViews.removeAll(keepCapacity: true)

        colllectionView.delegate = self.altDelegate
        colllectionView.dataSource = self.altDataSource
        
        self.colllectionView = nil
    }
}

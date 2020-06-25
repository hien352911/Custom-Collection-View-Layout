//
//  PinterestLayout.swift
//  Pinterest
//
//  Created by MTQ on 6/25/20.
//  Copyright © 2020 Razeware LLC. All rights reserved.
//

import UIKit

protocol PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {
    
    var delegate: PinterestLayoutDelegate!
    var numberOfColumns = 1 // số cột
    var cellPadding: CGFloat = 5
    
    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    private var width: CGFloat {
        get {
            let insets = collectionView!.contentInset
            return collectionView!.bounds.width - (insets.left + insets.right)
        }
    }
    
    // 2
    override var collectionViewContentSize: CGSize {
        return CGSize(width: width, height: contentHeight)
    }
    
    // 1. Tính toán frame cho mỗi cell ở đây, set đủ numberOrRow thì chạy đến collectionViewContentSize
    // Func này chạy 1 lần rồi đến collectionViewContentSize, ko phải lặp nhiều lần như cellForRow
    override func prepare() {
        if cache.isEmpty {
            let columnWidth = width / CGFloat(numberOfColumns)
            
            var xOffsets = [CGFloat]()
            for column in 0..<numberOfColumns {
                xOffsets.append(CGFloat(column) * columnWidth)
            }
            
            
            var yOffsets = Array<CGFloat>(repeating: 0, count: numberOfColumns)
            
            var column = 0
            for item in 0..<collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                let height = delegate.collectionView(collectionView!, heightForItemAtIndexPath: indexPath)
                
                // Tính frame của mỗi cell
                let frame = CGRect(x: xOffsets[column],
                                   y: yOffsets[column],
                                   width: columnWidth,
                                   height: height)
                // frame.x + dx
                // frame.y + dy
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                attributes.frame = insetFrame
                cache.append(attributes)
                
                // Tính contentSize của collectionView
                // Vì scroll dọc, nên chỉ cần tính height
                contentHeight = max(contentHeight, frame.maxY)
                
                // Note lại y của cell cuối để tính y của cell tiếp theo
                // Cell(n+1).y = cell(n).y + cell(n).height
                yOffsets[column] = yOffsets[column] + height
                
                if column >= (numberOfColumns - 1) {
                    column = 0
                } else {
                    column += 1
                }
            }
        }
    }
    
    // Giống cellWillDisplay ở chỗ
    // Lần đầu vào, thì chạy để nói cho collectionview biết [UICollectionViewLayoutAttributes] của những cell sẽ hiển thị
    // Khi scroll tiếp thì lại chạy vào
    // Nhưng khi đã có đủ rồi thì ko chạy lại nữa
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
}

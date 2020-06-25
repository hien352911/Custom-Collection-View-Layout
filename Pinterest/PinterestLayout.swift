//
//  PinterestLayout.swift
//  Pinterest
//
//  Created by MTQ on 6/25/20.
//  Copyright © 2020 Razeware LLC. All rights reserved.
//

import UIKit

protocol PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForPhotoAtIndexPath indexPath: IndexPath,
                        withWidth width: CGFloat) -> CGFloat
    
    func collectionView(_ collectionView: UICollectionView,
                        heightForAnnotationAtIndexPath indexPath: IndexPath,
                        withWidth width: CGFloat) -> CGFloat
}

class PinterestLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var photoHeight: CGFloat = 0
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! PinterestLayoutAttributes
        copy.photoHeight = photoHeight
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? PinterestLayoutAttributes {
            if attributes.photoHeight == photoHeight {
                return super.isEqual(object)
            }
        }
        return false
    }
}

class PinterestLayout: UICollectionViewLayout {
    
    var delegate: PinterestLayoutDelegate!
    var numberOfColumns = 1 // số cột
    var cellPadding: CGFloat = 5
    
    private var cache = [PinterestLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    private var width: CGFloat {
        get {
            let insets = collectionView!.contentInset
            return collectionView!.bounds.width - (insets.left + insets.right)
        }
    }
    
    override class var layoutAttributesClass: AnyClass {
        return PinterestLayoutAttributes.self
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
                
                let width = columnWidth - (cellPadding * 2)
                let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath, withWidth: width)
                let annotationHeight = delegate.collectionView(collectionView!, heightForAnnotationAtIndexPath: indexPath, withWidth: width)
                
                let height = cellPadding + photoHeight + annotationHeight + cellPadding
                
                // Tính frame của mỗi cell
                let frame = CGRect(x: xOffsets[column],
                                   y: yOffsets[column],
                                   width: columnWidth,
                                   height: height)
                // insetFrame.x = frame.x + dx
                // insetFrame.width = frame.width - dx * 2
                // insetFrame.height = frame.height - dy * 2
                // insetFrame.y = frame.y + dy
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                let attributes = PinterestLayoutAttributes(forCellWith: indexPath)
                
                attributes.frame = insetFrame
                attributes.photoHeight = photoHeight
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

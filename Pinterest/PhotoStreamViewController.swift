//
//  PhotoStreamViewController.swift
//  RWDevCon
//
//  Created by Mic Pringle on 26/02/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoStreamViewController: UICollectionViewController {
  
  var photos = Photo.allPhotos()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let patternImage = UIImage(named: "Pattern") {
      view.backgroundColor = UIColor(patternImage: patternImage)
    }
    
    collectionView!.backgroundColor = UIColor.clear
    collectionView!.contentInset = UIEdgeInsets(top: 23, left: 5, bottom: 10, right: 5)
    
    let layout = PinterestLayout()
    layout.delegate = self
    layout.numberOfColumns = 2
    collectionView.collectionViewLayout = layout
  }
  
}

extension PhotoStreamViewController {
  
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnnotatedPhotoCell", for: indexPath) as! AnnotatedPhotoCell
        
        cell.photo = photos[indexPath.item]
        
        return cell
    }
  
}

extension PhotoStreamViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let photo = photos[indexPath.row]
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        // Func generate rect with ratio
        // Dùng tay tính cũng được
        // ratio = photo.image.size.width / photo.image.size.height
        // rect.height = width / ratio
        let rect = AVMakeRect(aspectRatio: photo.image.size, insideRect: boundingRect)
        return rect.height
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        
        // 1
        let photo = photos[indexPath.row]
        
        // 2
        let font = UIFont(name: "AvenirNext-Regular", size: 10)!
        
        // 3
        let commentHeight = photo.heightForComment(font: font, width: width)
        
        // 4
        let height = 4 + 17 + 4 + commentHeight + 4
        
        return height
    }
}

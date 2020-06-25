//
//  PhotoStreamViewController.swift
//  RWDevCon
//
//  Created by Mic Pringle on 26/02/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

class PhotoStreamViewController: UICollectionViewController {
  
  var colors: [UIColor] {
    get {
        var colors = [UIColor]()
        let palette = [UIColor.red, UIColor.green, UIColor.blue, UIColor.orange, UIColor.purple, UIColor.yellow]
        var paletteIndex = 0
        for i in 0..<photos.count {
            colors.append(palette[paletteIndex])
            if paletteIndex == (palette.count - 1) {
                paletteIndex = 0
            } else {
                paletteIndex += 1
            }
        }
        return colors
    }
    }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IndexCollectionViewCell", for: indexPath) as! IndexCollectionViewCell
        cell.contentView.backgroundColor = colors[indexPath.item]
        cell.label.text = "\(indexPath.row)"
        return cell
    }
  
}

extension PhotoStreamViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        // arc4random_uniform(4)
        // [0...3]
        let random = arc4random_uniform(4) + 1
        return CGFloat(random * 100)
    }
}

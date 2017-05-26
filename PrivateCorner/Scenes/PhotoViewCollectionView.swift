//
//  PhotoViewCollectionView.swift
//  PrivateCorner
//
//  Created by a on 5/26/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

extension PhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.countPhoto()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell {
            viewModel.configure(cell: photoCell, atIndex: indexPath.item)
            photoCell.imageView.heroID = "image_\(indexPath.row)"
            photoCell.imageView.heroModifiers = [.position(CGPoint(x:view.bounds.width/2, y:view.bounds.height + view.bounds.width/2)), .scale(0.6), .fade]
            photoCell.topInset = topLayoutGuide.length
            photoCell.bottomInset = bottomLayoutGuide.length
            photoCell.imageView.isOpaque = true
            
            return photoCell
            
        }
        
        return UICollectionViewCell()
    }
}

extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.bounds.size
    }
}

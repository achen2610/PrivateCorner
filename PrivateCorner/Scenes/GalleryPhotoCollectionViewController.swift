//
//  GalleryPhotoCollectionViewController.swift
//  PrivateCorner
//
//  Created by a on 3/30/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

extension GalleryPhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.countPhoto()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifiers.galleryCell, for: indexPath) as? GalleryCell {

            cell.styleUI()
            viewModel.configure(cell:cell, atIndex:indexPath.row)
            
            cell.photoImageView.heroID = "image_\(indexPath.row)"
            cell.photoImageView.heroModifiers = [.fade, .scale(0.8)]
            cell.photoImageView.isOpaque = true
            
            cell.durationLabel.heroModifiers = [.fade]
            cell.shadowView.heroModifiers = [.fade]
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    // MARK: UICollectionView FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return cellLayout.cellSize
    }
    
    // MARK: UICollectionView Delegate    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GalleryCell

        if !isEditMode {
            selectedPhotoAtIndex(index: indexPath, cell: cell)
            
            cell.backgroundImageView.backgroundColor = UIColor.clear
            cell.backgroundImageView.alpha = 1.0
        }
    }
}

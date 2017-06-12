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
        return viewModel.numberOfSection()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return viewModel.setUpCollectionViewCell(indexPath: indexPath, collectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GalleryCell {
            if arraySelectedCell[indexPath.row] as Bool {
                cell.containerView.isHidden = false
                cell.selectedImageView.isHidden = false
            } else {
                cell.containerView.isHidden = true
                cell.selectedImageView.isHidden = true
            }
        }
    }
    
    // MARK: UICollectionView FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return viewModel.cellSize()
    }
    
    // MARK: UICollectionView Delegate    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GalleryCell

        if !isEditMode {
            selectedPhotoAtIndex(index: indexPath, cell: cell)
            
            cell.containerView.isHidden = true
            cell.selectedImageView.isHidden = true
            return
        }
        
        collectionView.deselectItem(at: indexPath, animated: false)
        arraySelectedCell[indexPath.row] = !arraySelectedCell[indexPath.row]
        cell.containerView.isHidden = !cell.containerView.isHidden
        cell.selectedImageView.isHidden = !cell.selectedImageView.isHidden
    }

}

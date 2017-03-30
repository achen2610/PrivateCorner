//
//  AlbumsCollectionViewController.swift
//  PrivateCorner
//
//  Created by a on 3/16/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

extension AlbumsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifiers.albumsCell, for: indexPath) as? AlbumsCell {
            cell.photoImageView.layer.cornerRadius = 5.0
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    // MARK: UICollectionView FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = cellLayout.sectionInsets.left * (cellLayout.itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / cellLayout.itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return cellLayout.sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellLayout.sectionInsets.left
    }
    
    // MARK: UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedGalleryAtIndex(index: indexPath.row)
    }
}

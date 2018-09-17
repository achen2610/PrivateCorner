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
        return viewModel.numberSection()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberItemInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.cellIdentifier(), for: indexPath) as? AlbumsCell {
            
            cell.configureLayout()
            cell.albumName.delegate = self
            cell.albumName.tag = indexPath.row
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: #selector(clickDeleteAlbum), for: .touchUpInside)
            if indexPath.section == 0 {
                cell.setEditMode(isEdit: isEditMode)
            } else {
                cell.deleteButton.isHidden = true
                cell.albumName.isEnabled = false
                cell.totalItem.isUserInteractionEnabled = false
                cell.photoImageView.isUserInteractionEnabled = false
            }
            
            let index = indexPath.row
            viewModel.fillUI(cell: cell, inSection: indexPath.section, atIndex: index)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    // MARK: UICollectionView FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = viewModel.sectionInsets().left * (viewModel.itemsPerRow() + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / viewModel.itemsPerRow()
        
        return CGSize(width: widthPerItem, height: widthPerItem + 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return viewModel.sectionInsets()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return viewModel.sectionInsets().left
    }
    
    // MARK: UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditMode {
            return
        }
        
        viewModel.selectedGalleryAtIndex(index: indexPath.row, section: indexPath.section)
    }
}

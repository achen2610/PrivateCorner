//
//  GalleryPhotoCollectionViewController.swift
//  PrivateCorner
//
//  Created by a on 3/30/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

extension GalleryPhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionView DataSource
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
            if viewModel.arraySelectedCell[indexPath.row] as Bool {
                cell.containerView.isHidden = false
                cell.selectedImageView.isHidden = false
            } else {
                cell.containerView.isHidden = true
                cell.selectedImageView.isHidden = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView = UICollectionReusableView()
        
        if kind == UICollectionView.elementKindSectionFooter {
            if let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterView", for: indexPath) as? GalleryCollectionFooterView {
                if viewModel.numberOfItemInSection(section: 0) > 0 {
                    footerView.footerLabel.text = viewModel.getCountPhotosAndVideos()
                } else {
                    footerView.footerLabel.text = ""
                }
                
                reusableView = footerView
            }
        }
        
        return reusableView
    }
    
    // MARK: - UICollectionView FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.cellSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GalleryCell

        if !isEditMode {
            viewModel.selectCollectionViewCell(indexPath: indexPath)
            
            cell.containerView.isHidden = true
            cell.selectedImageView.isHidden = true
            return
        }

        collectionView.deselectItem(at: indexPath, animated: false)
        viewModel.arraySelectedCell[indexPath.row] = !viewModel.arraySelectedCell[indexPath.row]
        cell.containerView.isHidden = !cell.containerView.isHidden
        cell.selectedImageView.isHidden = !cell.selectedImageView.isHidden
        
        updateStateEditButton()
        updateTitlePhotoSelected()
    }
}

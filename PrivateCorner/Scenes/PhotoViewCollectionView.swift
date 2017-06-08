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

        let type = viewModel.getTypeItem(index: indexPath.row)
        if type == "image" {
            if let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifiers.photoCell, for: indexPath) as? PhotoCell {
                viewModel.configure(cell: photoCell, atIndex: indexPath.item)
                photoCell.delegate = self
                photoCell.imageView.heroID = "image_\(indexPath.row)"
                photoCell.imageView.heroModifiers = [.position(CGPoint(x:view.bounds.width/2, y:view.bounds.height + view.bounds.width/2)), .scale(0.8), .fade]
                photoCell.imageView.isOpaque = true
                
                return photoCell
            }
        } else {
            if let videoCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifiers.videoCell, for: indexPath) as? VideoCell {
                viewModel.configure(cell: videoCell, atIndex: indexPath.item)
                videoCell.delegate = self
                videoCell.containerView.heroID = "image_\(indexPath.row)"
                videoCell.containerView.heroModifiers = [.position(CGPoint(x:view.bounds.width/2, y:view.bounds.height + view.bounds.width/2)), .scale(0.8), .fade]
                videoCell.playButton.heroModifiers = [.fade]
                return videoCell
            }
        }

        return UICollectionViewCell()
    }
}

extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.bounds.size
    }
}

extension PhotoViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let pageWidth = collectionView.frame.size.width
        let currentPage = collectionView.contentOffset.x / pageWidth
        
        let type = viewModel.getTypeItem(index: Int(currentPage))
        if type == "image" {
            actionButton.isEnabled = false
        } else {
            actionButton.isEnabled = true
        }
    }
}

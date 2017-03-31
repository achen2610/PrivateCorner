//
//  ImportCollectionViewController.swift
//  PrivateCorner
//
//  Created by a on 3/31/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

extension ImportViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: UICollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifiers.importCell, for: indexPath) as? ImportCell {
            cell.importImageView.layer.cornerRadius = 5.0
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    // MARK: UICollectionView FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellLayout.widthPerItem, height: cellLayout.widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let size = CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height - kNavigationView - kTabBar)
        let insets = UIEdgeInsetsMake((size.height - cellLayout.widthPerItem * 2) / 3, (size.width - cellLayout.widthPerItem * 2) / 4, (size.height - cellLayout.widthPerItem * 2) / 3, (size.width - cellLayout.widthPerItem * 2) / 4)
        return insets
        
//        return cellLayout.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        let height: CGFloat = collectionView.frame.size.height - kNavigationView - kTabBar
        return (height - cellLayout.widthPerItem * 2) / 3

//        return cellLayout.sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let width: CGFloat = collectionView.frame.size.width
        return (width - cellLayout.widthPerItem * 2) / 4
    }
    
    // MARK: UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImportDetailAtIndex(index: indexPath.row)
    }
}

//
//  ChooseAlbumCollectionViewController.swift
//  PrivateCorner
//
//  Created by a on 8/29/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

extension ChooseAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: UICollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return viewModel.numberOfItemInSection(section: section)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.cellIdentifier(), for: indexPath) as? ChooseAlbumCell {
            cell.configureLayout()
            
            if indexPath.section == 0 {
                cell.albumName.text = "Add new album"
                cell.photoImageView.image = UIImage(named: "albums.png")
                cell.totalItem.text = ""
            } else {
                let index = indexPath.row
                viewModel.fillUI(cell: cell, atIndex: index)
            }

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
        if indexPath.section == 0 {
            let alert = UIAlertController.init(title: "New Album", message: "Enter a name for this album", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.keyboardType = .alphabet
                textField.placeholder = "Title"
            }
            
            let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            let saveAction = UIAlertAction.init(title: "Save", style: .default) { (action) in
                let textField = alert.textFields?.first
                if let text = textField?.text, text != "" {
                    self.albumsCollectionView.performBatchUpdates({
                        self.viewModel.saveAlbumToCoreData(title: (textField?.text)!)
                        self.albumsCollectionView.insertItems(at: [IndexPath.init(row: 0, section: 1)])
                    }) { (finished) in
                        
                    }
                }
            }
            alert.addAction(saveAction)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            viewModel.selectAlbumAtIndex(index: indexPath.row)
        }
    }
}

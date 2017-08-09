//
//  WebViewCollectionViewController.swift
//  PrivateCorner
//
//  Created by a on 7/27/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

extension WebViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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

    // MARK: - UICollectionView FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.cellSize()
    }
    
    // MARK: - UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectCollectionViewCell(indexPath: indexPath)
        showCollectionView(show: false)
    }
    
}

//
//  CollectionViewExtension.swift
//  PrivateCorner
//
//  Created by a on 6/2/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

extension UICollectionView {
    func deselectAllItems(animated: Bool = false) {
        for indexPath in self.indexPathsForSelectedItems ?? [] {
            self.deselectItem(at: indexPath, animated: animated)
        }
    }
    
    func selectAllItems(section: Int = 0, animated: Bool = false) {
        for index in 0...self.numberOfItems(inSection: section) - 1 {
            self.selectItem(at: IndexPath(item: index, section: section), animated: animated, scrollPosition: .top)
        }
    }
}

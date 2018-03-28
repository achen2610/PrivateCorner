//
//  AddFileViewModel.swift
//  PrivateCorner
//
//  Created by a on 6/13/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit

public protocol MoveFileViewModelDelegate: class {
    func moveFileToAlbum(onSuccess: Bool)
}

open class MoveFileViewModel {
    
    fileprivate var albums: [Album] = []
    fileprivate var selectedItems: [Item] = []
    fileprivate var currentAlbum: Album
    weak var delegate: MoveFileViewModelDelegate?
    
    struct cellIdentifiers {
        static let moveFileCell = "MoveFileCell"
    }
    
    struct cellLayout {
        static let itemsPerRow: CGFloat = 2
        static let sectionInsets: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    public init(items: [Item], album: Album) {
        selectedItems = items
        currentAlbum = album
    }
    
    func getAlbumFromCoreData() {
        albums = AlbumManager.sharedInstance.getAlbums()
//        delegate?.reloadAlbum()
    }
    
    func sectionInsets() -> UIEdgeInsets {
        return cellLayout.sectionInsets
    }
    
    func itemsPerRow() -> CGFloat {
        return cellLayout.itemsPerRow
    }
    
    func cellIdentifier() -> String {
        return cellIdentifiers.moveFileCell
    }
    
    func numberOfItemInSection(section: Int) -> Int {
        return albums.count
    }
    
    func fillUI(cell: MoveFileCell, atIndex index: Int) {
        let album = albums[index]
        cell.albumName.text = album.name

        let array = ItemManager.sharedInstance.getItems(album: album)        
        if array.count > 0 {
            let lastItem = array.last
            
            if let thumbname = lastItem?.thumbName {
                if let directoryName = album.directoryName {
                    let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(thumbname)
                    cell.photoImageView.image = MediaLibrary.image(urlPath: path)
                } else {
                    let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.name!).appendingPathComponent(thumbname)
                    cell.photoImageView.image = MediaLibrary.image(urlPath: path)
                }
            }
            
            cell.totalItem.text = "\(array.count)"
        } else {
            cell.photoImageView.image = UIImage(named: "albums.png")
            cell.totalItem.text = "0"
        }
        
        if album == currentAlbum {
            cell.transparentView.isHidden = false
        } else {
            cell.transparentView.isHidden = true
        }
    }
    
    func selectAlbumAtIndex(index: Int) {
        let album = albums[index]
        if album == currentAlbum {
            return
        }
        
        // Move file
        ItemManager.sharedInstance.moveItem(items: selectedItems, fromAlbum: currentAlbum, toAlbum: album)
        
        // Send delegate when move done
        delegate?.moveFileToAlbum(onSuccess: true)
    }
}

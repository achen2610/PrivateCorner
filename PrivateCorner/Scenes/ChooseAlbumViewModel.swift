//
//  ChooseAlbumViewModel.swift
//  PrivateCorner
//
//  Created by a on 8/29/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit

public protocol ChooseAlbumViewModelDelegate: class {
    func chooseAlbumSuccess(onSuccess: Bool)
}

open class ChooseAlbumViewModel {

    fileprivate var albums: [Album] = []
    var selectedAlbum: Album?
    weak var delegate: ChooseAlbumViewModelDelegate?
    
    struct cellIdentifiers {
        static let chooseAlbum = "ChooseAlbumCell"
    }
    
    struct cellLayout {
        static let itemsPerRow: CGFloat = 2
        static let sectionInsets: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    func getAlbumFromCoreData() {
        albums = AlbumManager.sharedInstance.getAlbums()
    }
    
    func sectionInsets() -> UIEdgeInsets {
        return cellLayout.sectionInsets
    }
    
    func itemsPerRow() -> CGFloat {
        return cellLayout.itemsPerRow
    }
    
    func cellIdentifier() -> String {
        return cellIdentifiers.chooseAlbum
    }
    
    func numberOfItemInSection(section: Int) -> Int {
        return albums.count
    }
    
    func fillUI(cell: ChooseAlbumCell, atIndex index: Int) {
        let album = albums[index]
        cell.albumName.text = album.name
        
        let array = ItemManager.sharedInstance.getItems(album: album)
        if array.count > 0 {
            let lastItem = array.last
            
            if let thumbname = lastItem?.thumbName {
                let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.directoryName!).appendingPathComponent(thumbname)
                cell.photoImageView.image = MediaLibrary.image(urlPath: path)
            }
            
            cell.totalItem.text = "\(array.count)"
        } else {
            cell.photoImageView.image = UIImage(named: "albums.png")
            cell.totalItem.text = "0"
        }
    }
    
    func selectAlbumAtIndex(index: Int) {
        let album = albums[index]
        selectedAlbum = album
        
        delegate?.chooseAlbumSuccess(onSuccess: true)
    }
    
    
}

//
//  AlbumsViewModel.swift
//  PrivateCorner
//
//  Created by a on 5/22/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit

public protocol AlbumsViewModelDelegate: class {
    func navigationToAlbumDetail(viewModel: GalleryPhotoViewModel)
    func reloadAlbum()
}

open class AlbumsViewModel {
    
    fileprivate var albums: [Album] = []
    weak var delegate: AlbumsViewModelDelegate?
    
    public init(delegate: AlbumsViewModelDelegate) {
        self.delegate = delegate
        getAlbumFromCoreData()
    }
    
    func getAlbumFromCoreData() {
        albums = AlbumManager.sharedInstance.getAlbums()
        delegate?.reloadAlbum()
    }
    
    func countAlbum() -> Int {
        return albums.count
    }
    
    func saveAlbumToCoreData(title: String) {
        let album = AlbumManager.sharedInstance.addAlbum(title: title)
        self.albums.insert(album, at: 0)
    }
    
    func editAlbum(title: String, atIndex index: Int) {
        let album = albums[index]
        album.name = title
        albums[index] = album
        
        //1
        let managedContext = CoreDataManager.sharedInstance.managedObjectContext
        
        //2
        do {
            try managedContext.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func deleteAlbumFromList(index: Int) {
        let album = albums[index]
        AlbumManager.sharedInstance.deleteAlbum(album: album)
        self.albums.remove(at: index)
    }
    
    func fillUI(cell: AlbumsCell, atIndex index: Int) {
        let album = albums[index]
        cell.albumName.text = album.name
        
        
        let items = album.mutableSetValue(forKey: "items")
        let dateDescriptor = NSSortDescriptor(key: "uploadDate", ascending: false)
        let array = items.sortedArray(using: [dateDescriptor]) as! [Item]
        let lastImage = array.first
        
        if let filename = lastImage?.filename {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            let path = documentsDirectory.appendingPathComponent(filename)
            
            cell.photoImageView.sd_setImage(with: path, placeholderImage: UIImage(), options: [], completed: { (image, error, cacheType, imageURL) in
                //                self.photoImageView.alpha = 0.0
                //                UIView.animate(withDuration: 1.0, animations: {
                //                    self.photoImageView.alpha = 1.0
                //                })
            })
        }
        
        cell.totalItem.text = "\(array.count)"
    }
    
    func selectedGalleryAtIndex(index: Int) {
        let album = albums[index]
        
        let galleryModel = GalleryPhotoViewModel(album: album)
        delegate?.navigationToAlbumDetail(viewModel: galleryModel)
    }
    
}

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
    
    struct cellIdentifiers {
        static let albumsCell = "albumsCell"
    }
    
    struct cellLayout {
        static let itemsPerRow: CGFloat = 2
        static let sectionInsets: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    public init(delegate: AlbumsViewModelDelegate) {
        self.delegate = delegate
        getAlbumFromCoreData()
    }
    
    func getAlbumFromCoreData() {
        albums = AlbumManager.sharedInstance.getAlbums()
        delegate?.reloadAlbum()
    }
    
    func sectionInsets() -> UIEdgeInsets {
        return cellLayout.sectionInsets
    }
    
    func itemsPerRow() -> CGFloat {
        return cellLayout.itemsPerRow
    }
    
    func cellIdentifier() -> String {
        return cellIdentifiers.albumsCell
    }
    
    func numberOfItemInSection(section: Int) -> Int {
        return albums.count
    }
    
    func fillUI(cell: AlbumsCell, atIndex index: Int) {
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
    
    func selectedGalleryAtIndex(index: Int) {
        let album = albums[index]
        let galleryModel = GalleryPhotoViewModel(album: album)
        delegate?.navigationToAlbumDetail(viewModel: galleryModel)
    }
    
    func saveAlbumToCoreData(title: String) {
        let album = AlbumManager.sharedInstance.addAlbum(title: title)
        self.albums.insert(album, at: 0)
    }
    
    func editAlbum(title: String, atIndex index: Int) {
        let album = albums[index]
        
        //Get old name and new name album
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy-hh-mm-ss"
        let oldDirectoryName = album.directoryName!
        let newDirectoryName = title + "_" + dateFormatter.string(from: album.createdDate!)
        
        //Save name to core data
        album.name = title
        album.directoryName = newDirectoryName
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
        
        //3 Change name folder physical
        let fileManager = FileManager.default
        let albumPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(oldDirectoryName)
        let newAlbumPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.directoryName!)
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: albumPath.path, isDirectory: &isDir) {
            if isDir.boolValue {
                do {
                    try fileManager.moveItem(at: albumPath, to: newAlbumPath)
                } catch let error as NSError {
                    print("==============")
                    print("Rename album path")
                    print("Error : \(error.description)")
                }
            } else {
                print("Album path not a directory")
            }
        }
        
    }
    
    func deleteAlbumFromList(index: Int) {
        let album = albums[index]
        AlbumManager.sharedInstance.deleteAlbum(album: album)
        self.albums.remove(at: index)
    }
}

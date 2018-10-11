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
    fileprivate var specialAlbums: [Album] = []
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
    }
    
    func getAlbumFromCoreData() {
        let totalAlbums = AlbumManager.shared.getAlbums()
        albums = totalAlbums.filter{ $0.isSpecial == false }
        specialAlbums = totalAlbums.filter{ $0.isSpecial == true }
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
    
    func numberSection() -> Int {
        if specialAlbums.count > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func numberItemInSection(section: Int) -> Int {
        if section == 0 {
            return albums.count
        } else {
            return specialAlbums.count
        }
    }
    
    func fillUI(cell: AlbumsCell, inSection section: Int, atIndex index: Int) {
        let album = section == 0 ? albums[index] : specialAlbums[index]
        cell.albumName.text = album.name

        let directoryName = album.directoryName
        let array = ItemManager.shared.getItems(album: album)
        if array.count > 0 {
            let lastItem = array.last
            
            if let thumbname = lastItem?.thumbName {
                let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(thumbname)
                cell.photoImageView.image = MediaLibrary.image(urlPath: path)
            }
            
            cell.totalItem.text = "\(array.count)"
        } else {
            cell.photoImageView.image = UIImage(named: "albums.png")
            cell.totalItem.text = "0"
        }
        
    }
    
    func selectedGalleryAtIndex(index: Int, section: Int) {
        let album = section == 0 ? albums[index] : specialAlbums[index]
        let galleryModel = GalleryPhotoViewModel(album: album)
        delegate?.navigationToAlbumDetail(viewModel: galleryModel)
    }
    
    func saveAlbumToCoreData(title: String) {
        let album = AlbumManager.shared.addAlbum(title: title)
        self.albums.insert(album, at: 0)
    }
    
    func editAlbum(title: String, atIndex index: Int) {
        let album = albums[index]
        
        //Get old name and new name album
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy-hh-mm-ss"
        let oldDirectoryName = album.directoryName
        let newDirectoryName = title + "_" + dateFormatter.string(from: album.createdDate)
        
        //Save name to core data
        album.name = title
        album.directoryName = newDirectoryName
        albums[index] = album

        //1
        let managedContext = CoreDataManager.shared.managedObjectContext
        
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
        let newAlbumPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(newDirectoryName)
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
        AlbumManager.shared.deleteAlbum(album: album)
        albums.remove(at: index)
    }
}

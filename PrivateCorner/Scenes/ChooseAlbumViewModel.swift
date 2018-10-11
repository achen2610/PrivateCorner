//
//  ChooseAlbumViewModel.swift
//  PrivateCorner
//
//  Created by a on 8/29/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit
import Photos

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
        albums = AlbumManager.shared.getAlbums()
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
    
    func selectAlbumAtIndex(index: Int) {
        let album = albums[index]
        selectedAlbum = album
        
        delegate?.chooseAlbumSuccess(onSuccess: true)
    }
    
    func saveAlbumToCoreData(title: String) {
        let album = AlbumManager.shared.addAlbum(title: title)
        self.albums.insert(album, at: 0)
    }
    
    // Upload
    func uploadImageToCoreData(images: [UIImage], assets: [PHAsset], collectionView: UICollectionView) {
        
        guard let selectedAlbum = selectedAlbum else {
            return
        }
        
        let directoryName = selectedAlbum.directoryName
        let filenames = MediaLibrary.fetchImages(assets)
        
        let group = DispatchGroup()
        let percent: CGFloat = 100 / CGFloat(images.count * 2)
        var currentPercent: CGFloat = 0
        let fileManager = FileManager.default
        let currentIndex = Int(selectedAlbum.currentIndex)
        
        for image in images {
            let index = images.index(of: image)
            let name = filenames[index!]
            let subtype = MediaLibrary.getSubTypeOfFile(filename: name)
            let filename = String.init(format: "IMAGE_%i", currentIndex + index!) + "." + subtype
            let thumbname = "thumbnail" + "_" + filename
            
            // Add image to DB
            let info: [String: Any] = ["filename": filename, "thumbname": thumbname, "type": Key.ItemType.ImageType]
            ItemManager.shared.add(info: info, toAlbum: selectedAlbum)
            
            // Save original image
            let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(filename)
            if fileManager.fileExists(atPath: path.path) {
                print("===============")
                print("Image \(filename) exists")
            } else {
                group.enter()
                
                let data = autoreleasepool(invoking: { () -> Data? in
                    return image.pngData()
                })
                
                if let data = data {
                    let success = fileManager.createFile(atPath: path.path, contents: data, attributes: nil)
                    if success {
                        currentPercent += percent
//                        delegate?.updateProgressRing(value: currentPercent)
                        group.leave()
                    }
                }
            }
            
            // Save thumbnail image
            let thumbnailPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(thumbname)
            let thumbnailImage = MediaLibrary.getThumbnailImage(originalImage: image)
            if fileManager.fileExists(atPath: thumbnailPath.path) {
                print("===============")
                print("Thumbnail \(thumbname) exists")
            } else {
                group.enter()
                
                let data = autoreleasepool(invoking: { () -> Data? in
                    return thumbnailImage.pngData()
                })
                if let data = data {
                    let success = fileManager.createFile(atPath: thumbnailPath.path, contents: data, attributes: nil)
                    if success {
                        currentPercent += percent
//                        delegate?.updateProgressRing(value: currentPercent)
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            selectedAlbum.currentIndex = Int32(currentIndex + images.count)
            CoreDataManager.shared.saveContext()
     
            print("===============")
            print("Upload images success")
        }
    }
    
    //MARK: - Private Method
    
    
}

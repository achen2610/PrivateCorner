//
//  PhotoViewViewModel.swift
//  PrivateCorner
//
//  Created by a on 5/26/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit

open class PhotoViewViewModel {

    fileprivate var album = Album()
    fileprivate var items = [Item]()
    var isEndTransition: Bool = false
    
    public init(items: [Item], inAlbum album: Album) {
        self.items = items
        self.album = album
    }
    
    func numberOfItemInSection(section: Int) -> Int {
        return items.count
    }
    
    func configure(cell: Any, atIndex index: Int) {
        let item = items[index]
        
        if item.type == "image" {
            if let photoCell = cell as? PhotoCell {
                let urlPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.name!).appendingPathComponent(item.fileName!)
                photoCell.image = MediaLibrary.image(urlPath: urlPath)
            }
        } else {
            if let videoCell = cell as? VideoCell {
                let urlPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.name!).appendingPathComponent(item.fileName!)
                videoCell.configureVideo(url: urlPath, isEndTransition: isEndTransition)
            }
        }
    }
    
    func getTypeItem(index: Int) -> String {
        let item = items[index]
        return item.type!
    }
    
    func getUploadDate(index: Int) -> [String] {
        let item = items[index]
        var title = [String]()
        if let uploadDate = item.uploadDate as Date? {
            let dateFormatter = DateFormatter()
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            dateFormatter.dateFormat = "MMM dd"
            let topText = dateFormatter.string(from: uploadDate)
            title.append(topText)
            
            dateFormatter.dateFormat = "h:mm a"
            let bottomText = dateFormatter.string(from: uploadDate)
            title.append(bottomText)
        }
        return title
    }
    
    func deleteItem(index: Int, collectionView: UICollectionView) {
        let fileManager = FileManager.default
        let item = items[index]
        
        // Delete item from database
        ItemManager.sharedInstance.deleteItem(item: item, atAlbum: album)
        
        // Delete file of item in documents
        if let filename = item.fileName {
            let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.name!).appendingPathComponent(filename)
            do {
                if fileManager.fileExists(atPath: path.path) {
                    try fileManager.removeItem(at: path)
                } else {
                    print("===============")
                    print("File not exists")
                    print("Can't delete file : \(filename)")
                }
            } catch {
                print("===============")
                print("Error remove item \(filename), \(error)")
            }
        }
        
        if let thumbname = item.thumbName {
            let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.name!).appendingPathComponent(thumbname)
            do {
                if fileManager.fileExists(atPath: path.path) {
                    try fileManager.removeItem(at: path)
                } else {
                    print("===============")
                    print("File not exists")
                    print("Can't delete file : \(thumbname)")
                }
            } catch {
                print("===============")
                print("Error remove item \(thumbname), \(error)")
            }
        }
        
        let oldItems = items
        items.remove(at: index)
        collectionView.animateItemChanges(oldData: oldItems, newData: items)
    }
}


//
//  ItemManager.swift
//  PrivateCorner
//
//  Created by a on 3/31/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ItemManager {
    
    // MARK: - Item Manager stack
    static let sharedInstance = ItemManager()
    
    // MARK: - Public Methods
    func getItems(album: Album) -> [Item] {
        let temp = album.mutableSetValue(forKey: "items")
        let dateDescriptor = NSSortDescriptor(key: "uploadDate", ascending: true)
        let array = temp.sortedArray(using: [dateDescriptor]) as! [Item]
        
        return array
    }
    
    func saveContext() {
        //1
        let managedContext = CoreDataManager.sharedInstance.managedObjectContext
        
        //2
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func add(media: Any, info: [String: Any], toAlbum album: Album) {
        //1
        let managedContext = CoreDataManager.sharedInstance.managedObjectContext
        
        //2
        let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: managedContext) as! Item
        item.fileName = info["filename"] as? String
        item.thumbName = info["thumbname"] as? String
        item.uploadDate = Date() as NSDate?
        switch info["type"] as! Key.ItemType {
        case .ImageType:
            item.type = "image"
            break;
        case .VideoType:
            item.type = "video"
            if let media = media as? Video {
                item.duration = media.duration
            }
            break;
        }

        //3
        let itemsInAlbum = album.mutableSetValue(forKey: "items")
        if itemsInAlbum.count > 0 {
            itemsInAlbum.add(item)
        } else {
            album.addToItems(NSSet(array: [item]))
        }
    }
    
    func deleteItem(item: Item, atAlbum album: Album) {
        //1
        let managedContext = CoreDataManager.sharedInstance.managedObjectContext
        
        //2
        managedContext.delete(item)
        
        //3
        let itemsInAlbum = album.mutableSetValue(forKey: "items")
        if itemsInAlbum.count > 0 {
            itemsInAlbum.remove(item)
        }
        
        //4
        saveContext()
    }
    
    func moveItem(items: [Item], fromAlbum: Album, toAlbum: Album) {
        //1 Update uploadDate when move file
        let fileManager = FileManager.default
        let currentIndex = toAlbum.currentIndex
        for item in items {
            item.uploadDate = Date() as NSDate?
            let index = items.index(of: item)
            let subtype = MediaLibrary.getSubTypeOfFile(filename: item.fileName!)
            let type: String = item.type!.uppercased()
            
            //large image
            let filePath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(fromAlbum.name!).appendingPathComponent(item.fileName!)
            if fileManager.fileExists(atPath: filePath.path) {
                let filename = String.init(format: "%@_%i", type, currentIndex + Int32(index!)) + "." + subtype
                item.fileName = filename
                let newPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(toAlbum.name!).appendingPathComponent(filename)
                do {
                    try fileManager.moveItem(at: filePath, to: newPath)
                } catch let error as NSError {
                    print("================")
                    print("Move \(item.fileName!) error")
                    print(error.debugDescription)
                }
                
            }
            
            //thumb image
            let thumbPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(fromAlbum.name!).appendingPathComponent(item.thumbName!)
            if fileManager.fileExists(atPath: thumbPath.path) {
                let filename = "thumbnail" + "_" + String.init(format: "%@_%i", type, currentIndex + Int32(index!)) + "." + subtype
                item.thumbName = filename
                let newPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(toAlbum.name!).appendingPathComponent(filename)
                do {
                    try fileManager.moveItem(at: thumbPath, to: newPath)
                } catch let error as NSError {
                    print("================")
                    print("Move \(item.fileName!) error")
                    print(error.debugDescription)
                }
            }
        }
        toAlbum.currentIndex = currentIndex + Int32(items.count)
        
        //2
        let itemsInFromAlbum = fromAlbum.mutableSetValue(forKey: "items")
        if itemsInFromAlbum.count > 0 {
            for item in items {
                itemsInFromAlbum.remove(item)
            }
        }
        
        //3 
        let itemsInToAlbum = toAlbum.mutableSetValue(forKey: "items")
        if itemsInToAlbum.count > 0 {
            itemsInToAlbum.addObjects(from: items)
        } else {
            toAlbum.addToItems(NSSet(array: items))
        }
        
        //4
        saveContext()
    }
}

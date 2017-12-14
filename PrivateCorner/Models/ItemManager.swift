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
    
    func getItems(urls: [URL]) -> [Item] {
        var items = [Item]()
        var ids = [NSManagedObjectID]()
        for url in urls {
            if let oid = CoreDataManager.sharedInstance.managedObjectId(url: url) {
                ids.append(oid)
            }
        }
        
        //1
        let managedContext = CoreDataManager.sharedInstance.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        
        //3
        do {
            items = try managedContext.fetch(fetchRequest) as! [Item]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        //4 Filter
        items = items.filter({ ids.contains($0.objectID) })
        
        return items
    }
    
    func add(info: [String: Any], toAlbum album: Album) {
        //1
        let managedContext = CoreDataManager.sharedInstance.managedObjectContext
        
        //2
        let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: managedContext) as! Item
        item.fileName = info["filename"] as? String
        item.thumbName = info["thumbname"] as? String
        item.uploadDate = Date()
        switch info["type"] as! Key.ItemType {
        case .ImageType:
            item.type = "image"
            break;
        case .VideoType:
            item.type = "video"
            if let duration = info["duration"] {
                item.duration = duration as! Double
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
        CoreDataManager.sharedInstance.saveContext()
    }
    
    func moveItem(items: [Item], fromAlbum: Album, toAlbum: Album) {
        //1 Update uploadDate when move file
        let fileManager = FileManager.default
        let currentIndex = toAlbum.currentIndex
        
        guard let fromDirectory = fromAlbum.directoryName else {
            return
        }
        
        guard let toDirectory = toAlbum.directoryName else {
            return
        }
        
        for item in items {
            item.uploadDate = Date()
            let index = items.index(of: item)
            var subtype = MediaLibrary.getSubTypeOfFile(filename: item.fileName!)
            let type: String = item.type!.uppercased()
            
            //large image
            let filePath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(fromDirectory).appendingPathComponent(item.fileName!)
            if fileManager.fileExists(atPath: filePath.path) {
                let filename = String.init(format: "%@_%i", type, currentIndex + Int32(index!)) + "." + subtype
                item.fileName = filename
                let newPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(toDirectory).appendingPathComponent(filename)
                do {
                    try fileManager.moveItem(at: filePath, to: newPath)
                } catch let error as NSError {
                    print("================")
                    print("Move \(item.fileName!) error")
                    print(error.debugDescription)
                }
                
            }
            
            //thumb image
            let thumbPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(fromDirectory).appendingPathComponent(item.thumbName!)
            if fileManager.fileExists(atPath: thumbPath.path) {
                if type == "VIDEO" {
                    subtype = "JPG"
                }
                let filename = "thumbnail" + "_" + String.init(format: "%@_%i", type, currentIndex + Int32(index!)) + "." + subtype
                item.thumbName = filename
                let newPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(toDirectory).appendingPathComponent(filename)
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
        CoreDataManager.sharedInstance.saveContext()
    }
}

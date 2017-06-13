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
        let entity = NSEntityDescription.entity(forEntityName: "Item", in: managedContext)!
        
        //3
        let item = Item(entity: entity, insertInto: managedContext)
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

        //4
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
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func moveItem(items: [Item], fromAlbum: Album, toAlbum: Album) {
        //1
        let managedContext = CoreDataManager.sharedInstance.managedObjectContext
        
        //2 Update uploadDate when move file
        for item in items {
            item.uploadDate = Date() as NSDate?
        }
        
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
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

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
    
    enum ItemType {
        case ImageType
        case VideoType
    }
    
    // MARK: - Item Manager stack
    static let sharedInstance = ItemManager()
    
    // MARK: - Public Methods
    func getItems() -> [Item] {
        let array = [Item]()
        
        
        return array
    }
    
    func getItem(id: NSInteger) -> Item {
        let item = Item()
        
        return item
    }
    
    func add(media: Any, filename: String, thumbname: String, type: ItemType) -> Item {
        //1
        let managedContext = CoreDataManager.sharedInstance.managedObjectContext
        
        //2
        let entity = NSEntityDescription.entity(forEntityName: "Item", in: managedContext)!
        
        //3
        let item = Item(entity: entity, insertInto: managedContext)
        item.fileName = filename
        item.thumbName = thumbname
        item.uploadDate = Date() as NSDate?
        switch type {
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
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        return item
    }
    
    func updateItem(id: NSInteger, item: Item) {
        
    }
    
    func deleteItem(id: NSInteger) {
        
    }
}

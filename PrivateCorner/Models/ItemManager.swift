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
    
    func getItems() -> [Item] {
        let array = [Item]()
        
        
        return array
    }
    
    func getItem(id: NSInteger) -> Item {
        let item = Item()
        
        return item
    }
    
    func add(image: UIImage, filename: String) -> Item {
        //1
        let managedContext = CoreDataManager.sharedInstance.managedObjectContext
        
        //2
        let entity = NSEntityDescription.entity(forEntityName: "Item", in: managedContext)!
        
        //3
        let item = Item(entity: entity, insertInto: managedContext)
        item.filename = filename
        item.type = "image"
        item.uploadDate = Date() as NSDate?
        
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

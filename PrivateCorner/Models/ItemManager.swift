//
//  ItemManager.swift
//  PrivateCorner
//
//  Created by a on 3/31/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation

class ItemManager {
    
    // MARK: - Item Manager stack
    static let sharedInstance = ItemManager()
    
    func getItems() -> [Item] {
        let array = [Item]()
        
        
        return array
    }
    
    func getItem(id: NSInteger) -> Item {
        let album = Item()
        
        return album
    }
    
    func add(item: Item) {
        
    }
    
    func updateItem(id: NSInteger, item: Item) {
        
    }
    
    func deleteItem(id: NSInteger) {
        
    }
}

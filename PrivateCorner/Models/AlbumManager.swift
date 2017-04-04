//
//  AlbumManager.swift
//  PrivateCorner
//
//  Created by a on 3/31/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import CoreData

class AlbumManager {
    
    // MARK: - Album Manager stack
    static let sharedInstance = AlbumManager()
    
    func getAlbums() -> [Album] {
        var array = [Album]()
        
        let managedContext = CoreDataManager.sharedInstance.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        
        //3
        do {
            array = try managedContext.fetch(fetchRequest) as! [Album]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
        return array
    }
    
    func getAlbum(id: NSInteger) -> Album {
        let album = Album()
        
        return album
    }
    
    func add(album: Album) {
        
    }
    
    func updateAlbum(id: NSInteger, album: Album) {
        
    }
    
    func deleteAlbum(id: NSInteger) {
        
    }
}

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
        //1
        let managedContext = CoreDataManager.sharedInstance.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")

        //3
        do {
            array = try managedContext.fetch(fetchRequest) as! [Album]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        array = array.reversed()
        
        return array
    }
    
    func getAlbum(id: NSInteger) -> Album {
        let album = Album()
        
        return album
    }
    
    func addAlbum(title: String) -> Album {
        //1
        let managedContext = CoreDataManager.sharedInstance.managedObjectContext
        
        //2
        let entity = NSEntityDescription.entity(forEntityName: "Album", in: managedContext)!
        
        //3
        let album = Album(entity: entity, insertInto: managedContext)
        album.name = title
        album.createdDate = Date() as NSDate?
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        return album
    }
    
    func updateAlbum(id: NSInteger, album: Album) {
        
    }
    
    func deleteAlbum(album: Album) {
        //1
        let managedContext = CoreDataManager.sharedInstance.managedObjectContext
        
        //2
        managedContext.delete(album)
        
        //3
        do {
            try managedContext.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}

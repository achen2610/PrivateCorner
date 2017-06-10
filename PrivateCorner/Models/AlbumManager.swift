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
        let array = album.mutableSetValue(forKey: "items")
        let dateDescriptor = NSSortDescriptor(key: "uploadDate", ascending: false)
        let items = array.sortedArray(using: [dateDescriptor]) as! [Item]
        for item in items {
            let fileManager = FileManager.default
            if let filename = item.fileName {
                let path = getDocumentsDirectory().appendingPathComponent(filename)
                if fileManager.fileExists(atPath: path.path) {
                    print("===========")
                    print("File Exists")
                    print("Delete file")
                    do {
                        try fileManager.removeItem(atPath: path.path)
                    } catch let error as NSError {
                        print("===========")
                        print("Delete error")
                        print(error.debugDescription)
                    }
                }
            }
            
            if let thumbname = item.thumbName {
                let path = getDocumentsDirectory().appendingPathComponent(thumbname)
                if fileManager.fileExists(atPath: path.path) {
                    print("===========")
                    print("Thumbnail Exists")
                    print("Delete thumbnail")
                    do {
                        try fileManager.removeItem(atPath: path.path)
                    } catch let error as NSError {
                        print("===========")
                        print("Delete error")
                        print(error.debugDescription)
                    }
                }
            }
        }
        
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
    
    // Private Method
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

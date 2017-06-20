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
        let album = NSEntityDescription.insertNewObject(forEntityName: "Album", into: managedContext) as! Album
        album.name = title
        album.createdDate = Date() as NSDate?
        album.currentIndex = 0
        
        //3
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        //4
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        let urlPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(title)
        if !fileManager.fileExists(atPath: urlPath.path, isDirectory: &isDir) {
            do {
                try fileManager.createDirectory(at: urlPath, withIntermediateDirectories: false, attributes: nil)
            }
            catch let error as NSError {
                print("====================")
                print("Create folder error")
                print(error.debugDescription)
            }
            
        }
        
        return album
    }
    
    func updateAlbum(id: NSInteger, album: Album) {
        
    }
    
    func deleteAlbum(album: Album) {
        //1
        let managedContext = CoreDataManager.sharedInstance.managedObjectContext
        let fileManager = FileManager.default
        
        //2
        let items = ItemManager.sharedInstance.getItems(album: album)
        for item in items {
            
//            if let filename = item.fileName {
//                let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(filename)
//                if fileManager.fileExists(atPath: path.path) {
//                    print("===========")
//                    print("File Exists")
//                    print("Delete file")
//                    do {
//                        try fileManager.removeItem(atPath: path.path)
//                    } catch let error as NSError {
//                        print("===========")
//                        print("Delete error")
//                        print(error.debugDescription)
//                    }
//                }
//            }
//            
//            if let thumbname = item.thumbName {
//                let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(thumbname)
//                if fileManager.fileExists(atPath: path.path) {
//                    print("===========")
//                    print("Thumbnail Exists")
//                    print("Delete thumbnail")
//                    do {
//                        try fileManager.removeItem(atPath: path.path)
//                    } catch let error as NSError {
//                        print("===========")
//                        print("Delete error")
//                        print(error.debugDescription)
//                    }
//                }
//            }
            managedContext.delete(item)
        }

        //3
        let albumPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.name!)
        if fileManager.fileExists(atPath: albumPath.path) {
            do {
                try fileManager.removeItem(at: albumPath)
            } catch let error as NSError {
                print("============")
                print("Remove album error")
                print(error.debugDescription)
            }
        }
        
        //4
        managedContext.delete(album)
        
        //5
        do {
            try managedContext.save()
            print("Saved!✅")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)⛔️")
        }
    }
}

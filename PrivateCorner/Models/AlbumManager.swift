//
//  AlbumManager.swift
//  PrivateCorner
//
//  Created by a on 3/31/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation

class AlbumManager {
    
    // MARK: - Album Manager stack
    static let sharedInstance = AlbumManager()
    
    func getAlbums() -> [Album] {
        let array = [Album]()
        
        
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

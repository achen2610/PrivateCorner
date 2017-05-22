//
//  GalleryPhotoViewModel.swift
//  PrivateCorner
//
//  Created by a on 5/22/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit

public protocol GalleryPhotoViewModelDelegate: class {

    func reloadGallery()
}


open class GalleryPhotoViewModel {
    
    fileprivate var album: Album
    var photos = [INSPhotoViewable]()
    weak var delegate: GalleryPhotoViewModelDelegate?
    
    public init(album: Album) {
        self.album = album
    }
    
    func getGallery() {
        let items = album.mutableSetValue(forKey: "items")
        let dateDescriptor = NSSortDescriptor(key: "uploadDate", ascending: false)
        photos = parseDataToPhotos(items: items.sortedArray(using: [dateDescriptor]) as! [Item])
        
        delegate?.reloadGallery()
    }
    
    func countPhoto() -> Int {
        return photos.count
    }
    
    func uploadImageToCoreData(images: [UIImage], filenames: [String]) {
        var items = [Item]()
        for image in images {
            let index = images.index(of: image)
            let filename = filenames[index!]
            let item = ItemManager.sharedInstance.add(image: image, filename: filename)
            items.append(item)
            
            let fileManager = FileManager.default
            let path = getDocumentsDirectory().appendingPathComponent(filename)
            if fileManager.fileExists(atPath: path.path) {
                print("File Exists")
            } else {
                if let data = UIImagePNGRepresentation(image) {
                    try? data.write(to: path)
                }
            }
        }
        
        
        let itemsInAlbum = album.mutableSetValue(forKey: "items")
        if itemsInAlbum.count > 0 {
            itemsInAlbum.addObjects(from: items)
        } else {
            album.addToItems(NSSet(array: items))
        }
        
        //1
        let managedContext = CoreDataManager.sharedInstance.managedObjectContext
        
        //2
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        getGallery()
    }
    
    func configure(photo: INSPhotoViewable, withCell cell: GalleryCell) {
        
        photo.loadImageWithCompletionHandler { [weak photo](image, error) in
            if let image = image {
                if let photo = photo as? INSPhoto {
                    photo.image = image
                }
                cell.photoImageView.image = image
            }
        }
    }

    // MARK: Private Method
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func parseDataToPhotos(items: [Item]) -> [INSPhotoViewable] {
        var array = [INSPhotoViewable]();
        
        for item in items {
            if let filename = item.filename {
                let path = getDocumentsDirectory().appendingPathComponent(filename)
                let photo = INSPhoto(imageURL: path, thumbnailImage: UIImage())
                if let caption = item.caption {
                    photo.attributedTitle = NSAttributedString(string: caption, attributes: [NSForegroundColorAttributeName: UIColor.white])
                }
                array.append(photo)
            }
        }
        
        return array
    }
}

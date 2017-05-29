//
//  GalleryPhotoViewModel.swift
//  PrivateCorner
//
//  Created by a on 5/22/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit
import Photos

public protocol GalleryPhotoViewModelDelegate: class {

    func reloadGallery()
}


open class GalleryPhotoViewModel {
    
    fileprivate var album: Album
    var urlPaths = [URL]()
    var titleAlbum: String
    weak var delegate: GalleryPhotoViewModelDelegate?
    
    public init(album: Album) {
        self.album = album
        self.titleAlbum = album.name!
    }
    
    func getGallery() {
        let items = album.mutableSetValue(forKey: "items")
        let dateDescriptor = NSSortDescriptor(key: "uploadDate", ascending: false)
        urlPaths = parseDataToPhotos(items: items.sortedArray(using: [dateDescriptor]) as! [Item])
        
        delegate?.reloadGallery()
    }
    
    func countPhoto() -> Int {
        return urlPaths.count
    }
    
    func uploadImageToCoreData(images: [UIImage], assets: [PHAsset]) {
        
        let filenames = fetchImages(assets)
        var items = [Item]()
        for image in images {
            let index = images.index(of: image)
            let filename = filenames[index!]
            let item = ItemManager.sharedInstance.add(image: image, filename: filename)
            items.append(item)
            
            let fileManager = FileManager.default
            // Save original image
            let path = getDocumentsDirectory().appendingPathComponent(filename)
            if fileManager.fileExists(atPath: path.path) {
                print("Original Image Exists")
            } else {
                if let data = UIImagePNGRepresentation(image) {
                    try? data.write(to: path)
                    
                    
                }
            }
            
            // Save thumbnail image
            let thumbnailPath = getDocumentsDirectory().appendingPathComponent("thumbnail_" + filename)
            let thumbnailImage = ImageLibrary.getThumbnailImage(originalImage: image)
            if fileManager.fileExists(atPath: thumbnailPath.path) {
                print("Thumbnail Exists")
            } else {
                if let data = UIImagePNGRepresentation(thumbnailImage) {
                    try? data.write(to: thumbnailPath)
                    
                    
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
    
    func uploadVideoToCoreData(assets: [PHAsset]) {
        
    }
    
    func configure(cell: GalleryCell, atIndex index: Int) {
        
        let urlPath = urlPaths[index]
        cell.photoImageView.image = ImageLibrary.thumbnail(urlPath: urlPath)
    }

    // MARK: Private Method
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func parseDataToPhotos(items: [Item]) -> [URL] {
        var array = [URL]();
        
        for item in items {
            if let filename = item.filename {
                let path = getDocumentsDirectory().appendingPathComponent(filename)
                array.append(path)
            }
        }
        
        return array
    }
    
    private func fetchImages(_ assets: [PHAsset]) -> [String] {
        var filenames = [String]()
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        let size: CGSize = CGSize(width: 720, height: 1280)
        
        for asset in assets {
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
                if let info = info {
                    if let filename = (info["PHImageFileURLKey"] as? NSURL)?.lastPathComponent {
                        //do sth with file name
                        filenames.append(filename)
                    } else {
                        var name: String
                        if let indexString = UserDefaults.standard.value(forKey: "IndexForImage") {
                            let index = Int(indexString as! String)
                            name = "IMAGE_\(index! + 1).JPG"
                            UserDefaults.standard.set("\(index! + 1)", forKey: "IndexForImage")
                        } else {
                            name = "IMAGE_0.JPG"
                            UserDefaults.standard.set("0", forKey: "IndexForImage")
                        }
                        filenames.append(name)
                        UserDefaults.standard.synchronize()
                    }
                }
            }
        }
        return filenames
    }
}

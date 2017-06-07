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
    func updateProgressRing(value: CGFloat)
}


open class GalleryPhotoViewModel {
    
    fileprivate var album: Album
    var items = [Item]()
    var titleAlbum: String
    weak var delegate: GalleryPhotoViewModelDelegate?
    
    public init(album: Album) {
        self.album = album
        self.titleAlbum = album.name!
    }
    
    func getGallery() {
        let temp = album.mutableSetValue(forKey: "items")
        let dateDescriptor = NSSortDescriptor(key: "uploadDate", ascending: true)
        items = temp.sortedArray(using: [dateDescriptor]) as! [Item]
        
        delegate?.reloadGallery()
    }
    
    func countPhoto() -> Int {
        return items.count
    }
    
    func uploadImageToCoreData(images: [UIImage], assets: [PHAsset]) {
        
        let filenames = fetchImages(assets)
        var items = [Item]()
        let group = DispatchGroup()
        let percent: CGFloat = 100 / CGFloat(images.count * 2)
        var currentPercent: CGFloat = 0

        for image in images {
            let index = images.index(of: image)
            let filename = filenames[index!]
            let thumbname = "thumbnail" + filename
            let item = ItemManager.sharedInstance.add(media: image, filename: filename, thumbname: thumbname, type: .ImageType)
            items.append(item)
            
            let fileManager = FileManager.default
            // Save original image
            let path = getDocumentsDirectory().appendingPathComponent(filename)
            if fileManager.fileExists(atPath: path.path) {
                print("Original Image Exists")
            } else {
                group.enter()
                if let data = UIImagePNGRepresentation(image) {
                    //                    try? data.write(to: path)
                    
                    let success = fileManager.createFile(atPath: path.path, contents: data, attributes: nil)
                    if success {
                        group.leave()
                        currentPercent += percent
                        delegate?.updateProgressRing(value: currentPercent)
                    }
                }
            }
            
            // Save thumbnail image
            let thumbnailPath = getDocumentsDirectory().appendingPathComponent(thumbname)
            let thumbnailImage = MediaLibrary.getThumbnailImage(originalImage: image)
            if fileManager.fileExists(atPath: thumbnailPath.path) {
                print("Thumbnail Exists")
            } else {
                group.enter()
                if let data = UIImagePNGRepresentation(thumbnailImage) {
                    //                    try? data.write(to: thumbnailPath)
                    
                    let success = fileManager.createFile(atPath: thumbnailPath.path, contents: data, attributes: nil)
                    if success {
                        group.leave()
                        currentPercent += percent
                        delegate?.updateProgressRing(value: currentPercent)
                    }
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
        
        group.notify(queue: DispatchQueue.main) { 
            self.getGallery()
        }
    }
    
    func uploadVideoToCoreData(video: Video, avasset: AVAsset) {
        
        if let avassetURL = avasset as? AVURLAsset {
            let videoUrl = avassetURL.url
            let group = DispatchGroup()
            let fileManager = FileManager.default
            let filename = avassetURL.url.lastPathComponent
            let name = filename.components(separatedBy: ".").first
            let thumbname = "thumbnail_" + name! + ".JPG"
            
            // Add video to database
            let item = ItemManager.sharedInstance.add(media: video, filename: filename, thumbname: thumbname, type: .VideoType)
            
            let itemsInAlbum = self.album.mutableSetValue(forKey: "items")
            if itemsInAlbum.count > 0 {
                itemsInAlbum.add(item)
            } else {
                self.album.addToItems(NSSet(array: [item]))
            }
            
            //1
            let managedContext = CoreDataManager.sharedInstance.managedObjectContext
            
            //2
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            // Save original video
            group.enter()
            let path = self.getDocumentsDirectory().appendingPathComponent(filename)
            if fileManager.fileExists(atPath: path.path) {
                print("Video Exists")
            } else {
                
                saveVideoFile(videoUrl: videoUrl, destinationPath: path)
                group.leave()
                delegate?.updateProgressRing(value: 50)
                
//                let success = fileManager.createFile(atPath: path.path, contents: videoData, attributes: nil)
//                if success {
//                    group.leave()
//                    delegate?.updateProgressRing(value: 50)
//                }
            }
            
            // Save thumbnail video
            group.enter()
            let thumbnailPath = self.getDocumentsDirectory().appendingPathComponent(thumbname)
            video.fetchThumbnail(CGSize(width: 512, height: 512), completion: { (image) in
                if fileManager.fileExists(atPath: thumbnailPath.path) {
                    print("Thumbnail Exists")
                } else {
                    if let data = UIImagePNGRepresentation(image!) {
                        let success = fileManager.createFile(atPath: thumbnailPath.path, contents: data, attributes: nil)
                        if success {
                            group.leave()
                            self.delegate?.updateProgressRing(value: 100)
                        }
                    }
                }
            })
            
            group.notify(queue: DispatchQueue.main, execute: { 
                self.getGallery()
            })
        }
    }
    
    func configure(cell: GalleryCell, atIndex index: Int) {
        
        let item = items[index]
        let urlPath = getDocumentsDirectory().appendingPathComponent(item.thumbName!)
        if item.type == "image" {

            cell.durationLabel.isHidden = true
            cell.shadowView.isHidden = true
        } else { //if item.type == "video" {
            
            //\(lround(floor(item.duration / 3600)) % 100)
            let string = String(format: "%02d", lround(floor(item.duration / 60)) % 60) + ":" + String(format: "%02d", lround(floor(item.duration)) % 60)
            cell.durationLabel.text = string
            cell.durationLabel.isHidden = false
            cell.shadowView.isHidden = false
        }
        
        cell.photoImageView.image = MediaLibrary.image(urlPath: urlPath)
//        cell.photoImageView.sd_setImage(with: urlPath)
    }

    // MARK: Private Method
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
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
    
    private func saveVideoFile(videoUrl: URL, destinationPath urlPath: URL) {
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: urlPath.path) {
            fileManager.createFile(atPath: urlPath.path, contents: Data.init(), attributes: nil)
        }
        
        let fileWriteHandle: FileHandle? = FileHandle.init(forWritingAtPath: urlPath.path)
        let fileReadHandle: FileHandle? = FileHandle.init(forReadingAtPath: videoUrl.path)
        
        var chunk = Data()
        let chunkSize = 64 * 1024
        var offset: UInt64 = 0
        
        var fileSize : UInt64 = 0
        do {
            //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: videoUrl.path)
            fileSize = attr[FileAttributeKey.size] as! UInt64
        } catch {
            print("Error: \(error)")
        }
        
        autoreleasepool {
            if let temp = fileReadHandle?.readData(ofLength: chunkSize) {
                chunk = temp
            }
        }

        while chunk.count > 0 {
            fileWriteHandle?.write(chunk)
            
            offset = offset + UInt64(chunk.count)
            fileReadHandle?.seek(toFileOffset: offset)
            
            autoreleasepool {
                if let temp = fileReadHandle?.readData(ofLength: chunkSize) {
                    chunk = temp
                }
            }
            
            let progress: CGFloat = CGFloat(offset) / CGFloat(fileSize) * 50
            delegate?.updateProgressRing(value: progress)
        }
        
        fileWriteHandle?.closeFile()
    }
}

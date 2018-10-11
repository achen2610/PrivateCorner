//
//  UploadManager.swift
//  PrivateCorner
//
//  Created by a on 6/14/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit
import Photos

class UploadManager  {
    
    // MARK: - Item Manager stack
    static let shared = UploadManager()
    
    // Variables
    var progressRing: UICircularProgressRingView
    var window: UIWindow!
    
    init() {
        
        window = UIApplication.shared.keyWindow
        
        progressRing = UICircularProgressRingView(frame: CGRect(x: 35, y: 0, width: 153, height: 153))
        // Change any of the properties you'd like
        let blue = UIColor(hexString: "#3498db")
        progressRing.outerRingColor = blue
        progressRing.outerRingWidth = 8.0
        progressRing.innerRingColor = blue.lighter()
        progressRing.innerRingSpacing = 0
        progressRing.fontColor = blue.darkened()
        progressRing.isHidden = true
        
        window.addSubview(progressRing)
    }
    
    public func uploadVideo(video: GVideo, videoPath: URL, destinationPath: URL, thumbPath: URL, delegate: GalleryPhotoViewModelDelegate?, completion: @escaping (Bool) -> Void) {
        
        let fileManager = FileManager.default
        video.fetchThumbnail(size: CGSize(width: 256, height: 256)) { (image) in

            if fileManager.fileExists(atPath: destinationPath.path) {
                print("===============")
                print("Video \(destinationPath.lastPathComponent) exists")
            } else {
                self.saveVideoFile(videoUrl: videoPath, destinationPath: destinationPath, delegate: delegate)
            }

            if fileManager.fileExists(atPath: thumbPath.path) {
                print("===============")
                print("Thumbnail \(thumbPath.lastPathComponent) exists")
                delegate?.updateProgressRing(value: 100)
                completion(true)
            } else {
                if let data = image!.pngData() {
                    let success = fileManager.createFile(atPath: thumbPath.path, contents: data, attributes: nil)
                    if success {
                        delegate?.updateProgressRing(value: 100)
                        completion(true)
                    }
                }
            }
        }
    }
    
    public func uploadVideo(videoPath: URL, destinationPath: URL, completion: @escaping (Bool) -> Void) {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: destinationPath.path) {
            print("===============")
            print("Video \(destinationPath.lastPathComponent) exists")
            completion(true)
        } else {
            do {
                try fileManager.moveItem(at: videoPath, to: destinationPath)
                completion(true)
            } catch let error as NSError {
                print("Error when move file \(error)")
                completion(false)
            }
        }
    }
    
    private func saveVideoFile(videoUrl: URL, destinationPath urlPath: URL, delegate: GalleryPhotoViewModelDelegate?) {
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
    
    
    
    // Upload Image to Core Data
    
    public func uploadImage(images: [UIImage], assets: [PHAsset], album: Album, completion: @escaping (Bool) -> Void) {
        
        self.progressRing.isHidden = false
        let filenames = MediaLibrary.fetchImages(assets)
        
        let group = DispatchGroup()
        let percent: CGFloat = 100 / CGFloat(images.count * 2)
        var currentPercent: CGFloat = 0
        let fileManager = FileManager.default
        let currentIndex = Int(album.currentIndex)
        let documentDirectory = MediaLibrary.getDocumentsDirectory()
        let directoryName = album.directoryName
        
        for image in images {
            let index = images.index(of: image)
            let name = filenames[index!]
            let subtype = MediaLibrary.getSubTypeOfFile(filename: name)
            let filename = String.init(format: "IMAGE_%i", currentIndex + index!) + "." + subtype
            let thumbname = "thumbnail" + "_" + filename
            
            // Add image to DB
            let info: [String: Any] = ["filename": filename, "thumbname": thumbname, "type": Key.ItemType.ImageType]
            ItemManager.shared.add(info: info, toAlbum: album)
            
            // Save original image
            let path = documentDirectory.appendingPathComponent(directoryName).appendingPathComponent(filename)
            if fileManager.fileExists(atPath: path.path) {
                print("===============")
                print("Image \(filename) exists")
            } else {
                group.enter()
                
                let data = autoreleasepool(invoking: { () -> Data? in
                    return image.pngData()
                })
                
                if let data = data {
                    let success = fileManager.createFile(atPath: path.path, contents: data, attributes: nil)
                    if success {
                        currentPercent += percent
                        self.progressRing.setProgress(value: currentPercent, animationDuration: 0.3)
                        group.leave()
                    }
                }
            }
            
            // Save thumbnail image
            let thumbnailPath = documentDirectory.appendingPathComponent(directoryName).appendingPathComponent(thumbname)
            let thumbnailImage = MediaLibrary.getThumbnailImage(originalImage: image)
            if fileManager.fileExists(atPath: thumbnailPath.path) {
                print("===============")
                print("Thumbnail \(thumbname) exists")
            } else {
                group.enter()
                let data = autoreleasepool(invoking: { () -> Data? in
                    return thumbnailImage.pngData()
                })
                if let data = data {
                    let success = fileManager.createFile(atPath: thumbnailPath.path, contents: data, attributes: nil)
                    if success {
                        currentPercent += percent
                        self.progressRing.setProgress(value: currentPercent, animationDuration: 0.3)
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            album.currentIndex = Int32(currentIndex + images.count)
            CoreDataManager.shared.saveContext()
            
            self.progressRing.setProgress(value: 0, animationDuration: 0)
            self.progressRing.isHidden = true
            
            completion(true)
        }
    }
    
    
    // Paste items from album to another album
    public func pasteItems(pasteItems: [Item], from fromAlbum: Album, to toAlbum: Album, completion: @escaping (Bool) -> Void) {
        
        let toDirectory = toAlbum.directoryName
        let fromDirectory = fromAlbum.directoryName
        
        let currentIndex = toAlbum.currentIndex
        let fileManager = FileManager.default
        let percent: CGFloat = 100 / CGFloat(pasteItems.count * 2)
        var currentPercent: CGFloat = 0
        let documentDirectory = MediaLibrary.getDocumentsDirectory()
        
        for (index, item) in pasteItems.enumerated() {
            
            let oldName = item.fileName
            let oldThumbName = item.thumbName
            let type = item.type
                
            let subtype = MediaLibrary.getSubTypeOfFile(filename: oldName)
            let newName = String.init(format: "%@_%i", type.uppercased(), currentIndex + Int32(index)) + "." + subtype
            var newThumbName = "thumbnail" + "_" + newName
            if type == "video" {
                newThumbName = "thumbnail" + "_" + String.init(format: "%@_%i", type.uppercased(), currentIndex + Int32(index)) + "." + "JPG"
            }
            
            // Add image/video to DB
            var info: [String: Any] = ["filename": newName,
                                       "thumbname": newThumbName,
                                       "type": Key.ItemType.ImageType]
            if type == "video" {
                info = ["filename": newName,
                        "thumbname": newThumbName,
                        "type": Key.ItemType.VideoType,
                        "duration": item.duration]
            }
            ItemManager.shared.add(info: info, toAlbum: toAlbum)
            
            // Copy image/video to folder album
            let imagePath = documentDirectory.appendingPathComponent(fromDirectory).appendingPathComponent(oldName)
            let newImagePath = documentDirectory.appendingPathComponent(toDirectory).appendingPathComponent(newName)
            if fileManager.fileExists(atPath: imagePath.path) {
                do {
                    try fileManager.copyItem(at: imagePath, to: newImagePath)
                } catch let error as NSError {
                    print("=============")
                    print("Copy \(oldName) to \(toDirectory) error : \(error.debugDescription)")
                }
                currentPercent += percent
                self.progressRing.setProgress(value: currentPercent, animationDuration: 0.3)
            }
            
            // Copy thumbnail to folder album
            let thumbPath = documentDirectory.appendingPathComponent(fromDirectory).appendingPathComponent(oldThumbName)
            let newThumbPath = documentDirectory.appendingPathComponent(toDirectory).appendingPathComponent(newThumbName)
            if fileManager.fileExists(atPath: thumbPath.path) {
                do {
                    try fileManager.copyItem(at: thumbPath, to: newThumbPath)
                } catch let error as NSError {
                    print("=============")
                    print("Copy \(oldThumbName) to \(toDirectory) error : \(error.debugDescription)")
                }
                currentPercent += percent
                self.progressRing.setProgress(value: currentPercent, animationDuration: 0.3)
            }
            
        }
        
        // Copy Item success
        toAlbum.currentIndex = currentIndex + Int32(pasteItems.count)
        CoreDataManager.shared.saveContext()
        
        // End block
        completion(true)
    }
}

//
//  ImportWebViewModel.swift
//  PrivateCorner
//
//  Created by a on 8/31/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit
import AVFoundation

public protocol ImportWebViewModelDelegate: class {
    
}

open class ImportWebViewModel {
    
    struct File {
        enum Extension {
            case Video
            case Image
            case NoSuitable
        }
    }
    
    weak var delegate: ImportWebViewModelDelegate?
    var album: Album
    
    public init(delegate: ImportWebViewModelDelegate) {
        self.delegate = delegate
        
        if let importAlbum = AlbumManager.sharedInstance.getAlbum(title: "Import") {
            album = importAlbum
        } else {
            album = AlbumManager.sharedInstance.addAlbum(title: "Import")
        }
    }
    
    private func checkFileExtension(path: String) -> File.Extension {
        var subtype: String
        let array = path.components(separatedBy: ".")
        subtype = array.last!
        if subtype == "mov" || subtype == "mp4" {
            return File.Extension.Video
        } else if subtype == "jpg" || subtype == "jpeg" || subtype == "gif" || subtype == "png" {
            return File.Extension.Image
        } else {
            return File.Extension.NoSuitable
        }
    }
    
    func saveFile(path: String, completion: @escaping(Bool) -> Void)  {
        let ext = checkFileExtension(path: path)
        switch ext {
        case .Video:
            saveVideo(path: path, completion: { (status) in
                if status {
                    completion(true)
                } else {
                    completion(false)
                }
            })
            break
        case .Image:
            saveImage(path: path, completion: { (status) in
                if status {
                    completion(true)
                } else {
                    completion(false)
                }
            })
            break
        case .NoSuitable:
            completion(false)
            break
        }
    }
    
    func saveVideo(path: String, completion: @escaping(Bool) -> Void) {
        let videoUrl = URL(fileURLWithPath: path)
        let name = videoUrl.lastPathComponent
        let currentIndex = album.currentIndex
        let subtype = MediaLibrary.getSubTypeOfFile(filename: name)
        let filename = String.init(format: "VIDEO_%i", currentIndex) + "." + subtype
        let thumbname = "thumbnail_" + String.init(format: "VIDEO_%i", currentIndex) + ".JPG"
        
        guard let directoryName = album.directoryName else {
            return
        }
        
        // Rename file
        let filePath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(filename)
        do {
            try FileManager.default.moveItem(at: videoUrl, to: filePath)
        } catch {
            print(error)
            completion(false)
        }
        
        let asset : AVURLAsset = AVURLAsset(url: filePath, options: nil)
        let duration : CMTime = asset.duration

        // Get thumb image video
        var thumbImage = UIImage()
        let generator = AVAssetImageGenerator(asset: asset)
        do {
            let frameRef = try generator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            thumbImage = UIImage(cgImage: frameRef)
        } catch let error as NSError {
            print("Error : \(error)")
            completion(false)
        }
        
        // Thumbnail path
        let thumbPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(thumbname)
        
        // Save thumbnail
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: thumbPath.path) {
            print("===============")
            print("Thumbnail \(thumbPath.lastPathComponent) exists")
        } else {
            if let data = UIImagePNGRepresentation(thumbImage) {
                fileManager.createFile(atPath: thumbPath.path, contents: data, attributes: nil)
            }
        }
        
        // Add video to database
        let info: [String: Any] = ["filename": filename,
                                   "thumbname": thumbname,
                                   "type": Key.ItemType.VideoType,
                                   "duration": CMTimeGetSeconds(duration)]
        ItemManager.sharedInstance.add(info: info, toAlbum: album)
        
        DispatchQueue.main.async {
            print("===============")
            print("Upload video success")
            self.album.currentIndex = currentIndex + 1
            CoreDataManager.sharedInstance.saveContext()
            
            completion(true)
        }
    }
    
    func saveImage(path: String, completion: @escaping(Bool) -> Void) {
        let fileManager = FileManager.default
        let imageUrl = URL(fileURLWithPath: path)
        let name = imageUrl.lastPathComponent
        let currentIndex = album.currentIndex
        let subtype = MediaLibrary.getSubTypeOfFile(filename: name)
        let filename = String.init(format: "IMAGE_%i", currentIndex) + "." + subtype
        let thumbname = "thumbnail" + "_" + filename
        
        guard let directoryName = album.directoryName else {
            return
        }
        
        // Add image to DB
        let info: [String: Any] = ["filename": filename, "thumbname": thumbname, "type": Key.ItemType.ImageType]
        ItemManager.sharedInstance.add(info: info, toAlbum: album)

        // Rename file
        let filePath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(filename)
        do {
            try fileManager.moveItem(at: imageUrl, to: filePath)
        } catch {
            print(error)
            completion(false)
        }
        
        // Save thumbnail image
        let image = UIImage(contentsOfFile: filePath.path)!
        let thumbnailPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(thumbname)
        let thumbnailImage = MediaLibrary.getThumbnailImage(originalImage: image)
        if fileManager.fileExists(atPath: thumbnailPath.path) {
            print("===============")
            print("Thumbnail \(thumbname) exists")
        } else {
            if let data = UIImagePNGRepresentation(thumbnailImage) {
                fileManager.createFile(atPath: thumbnailPath.path, contents: data, attributes: nil)
            }
        }
        
        album.currentIndex = currentIndex + 1
        CoreDataManager.sharedInstance.saveContext()

        print("===============")
        print("Upload image success")
        completion(true)
    }
}

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
    var album: Album?
    
    public init(delegate: ImportWebViewModelDelegate) {
        self.delegate = delegate
        
        if let importAlbum = AlbumManager.shared.getAlbum(title: "Import", isSpecial: true) {
            album = importAlbum
        } else {
            album = AlbumManager.shared.addAlbum(title: "Import", isSpecial: true)
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
        
        guard let album = self.album else {
            completion(false)
            return
        }
        
        let videoUrl = URL(fileURLWithPath: path)
        let name = videoUrl.lastPathComponent
        let currentIndex = album.currentIndex
        let subtype = MediaLibrary.getSubTypeOfFile(filename: name)
        let filename = String.init(format: "VIDEO_%i", currentIndex) + "." + subtype
        let thumbname = "thumbnail_" + String.init(format: "VIDEO_%i", currentIndex) + ".JPG"

        
        // Rename file
        let fileUrl = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.directoryName).appendingPathComponent(filename)
        do {
            try FileManager.default.moveItem(at: videoUrl, to: fileUrl)
        } catch {
            print(error)
            completion(false)
        }
        
        let asset : AVURLAsset = AVURLAsset(url: fileUrl, options: nil)
        let duration : CMTime = asset.duration

        // Get thumb image video
        var thumbImage = UIImage()
        let generator = AVAssetImageGenerator(asset: asset)
        do {
            let frameRef = try generator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            thumbImage = UIImage(cgImage: frameRef)
        } catch let error as NSError {
            print("Error : \(error)")
            completion(false)
        }
        
        // Thumbnail path
        let thumbUrl = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.directoryName).appendingPathComponent(thumbname)
        
        // Save thumbnail
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: thumbUrl.path) {
            print("===============")
            print("Thumbnail \(thumbUrl.lastPathComponent) exists")
        } else {
            if let data = thumbImage.pngData() {
                fileManager.createFile(atPath: thumbUrl.path, contents: data, attributes: nil)
            }
        }
        
        // Add video to database
        let info: [String: Any] = ["filename": filename,
                                   "thumbname": thumbname,
                                   "type": Key.ItemType.VideoType,
                                   "duration": CMTimeGetSeconds(duration)]
        ItemManager.shared.add(info: info, toAlbum: album)
        
        DispatchQueue.main.async {
            print("===============")
            print("Upload video success")
            album.currentIndex = currentIndex + 1
            CoreDataManager.shared.saveContext()
            
            completion(true)
        }
    }
    
    func saveImage(path: String, completion: @escaping(Bool) -> Void) {
        
        guard let album = self.album else {
            completion(false)
            return
        }
        
        let directoryName = album.directoryName
        let fileManager = FileManager.default
        let imageUrl = URL(fileURLWithPath: path)
        let name = imageUrl.lastPathComponent
        let currentIndex = album.currentIndex
        let subtype = MediaLibrary.getSubTypeOfFile(filename: name)
        let filename = String.init(format: "IMAGE_%i", currentIndex) + "." + subtype
        let thumbname = "thumbnail" + "_" + filename
        
        
        
        // Add image to DB
        let info: [String: Any] = ["filename": filename, "thumbname": thumbname, "type": Key.ItemType.ImageType]
        ItemManager.shared.add(info: info, toAlbum: album)

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
            if let data = thumbnailImage.pngData() {
                fileManager.createFile(atPath: thumbnailPath.path, contents: data, attributes: nil)
            }
        }
        
        album.currentIndex = currentIndex + 1
        CoreDataManager.shared.saveContext()

        print("===============")
        print("Upload image success")
        completion(true)
    }
}

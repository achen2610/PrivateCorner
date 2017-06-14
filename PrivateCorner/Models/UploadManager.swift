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
    static let sharedInstance = UploadManager()
    
    public func uploadVideo(video: Video, videoPath: URL, destinationPath: URL, thumbPath: URL, delegate: GalleryPhotoViewModelDelegate?, completion: @escaping (Bool) -> Void) {
        
        let fileManager = FileManager.default
        video.fetchThumbnail(CGSize(width: 256, height: 256)) { (image) in

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
                if let data = UIImagePNGRepresentation(image!) {
                    let success = fileManager.createFile(atPath: thumbPath.path, contents: data, attributes: nil)
                    if success {
                        delegate?.updateProgressRing(value: 100)
                        completion(true)
                    }
                }
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
}

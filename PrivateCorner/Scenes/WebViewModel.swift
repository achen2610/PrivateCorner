//
//  WebViewModel.swift
//  PrivateCorner
//
//  Created by a on 7/26/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public protocol WebViewModelDelegate: class {
    func updateProgressRing(value: CGFloat)
    func downloadComplete()
}

open class WebViewModel {
    
    fileprivate var album: Album
    fileprivate var listAlbum: [Album]
    fileprivate var filename: String?
    fileprivate var dataImage: Data?
    weak var delegate: WebViewModelDelegate?
    
    struct cellLayout {
        static let itemsPerRow: CGFloat = 3
        static let cellSize: CGSize = CGSize(width: kScreenWidth / CGFloat(itemsPerRow),
                                             height: kScreenWidth / CGFloat(itemsPerRow))
    }
    
    struct cellIdentifiers {
        static let webAlbumCell = "WebAlbumCell"
    }
    
    // MARK: - Public Methods
    public init() {
        self.album = Album()
        self.listAlbum = [Album]()
    }
    
    func cellSize() -> CGSize {
        return cellLayout.cellSize
    }
    
    func cellIdentifier() -> String {
        return cellIdentifiers.webAlbumCell
    }
    
    func numberOfItemInSection(section: Int) -> Int {
        return listAlbum.count
    }
    
    func numberOfSection() -> Int {
        return 1
    }
    
    func setUpCollectionViewCell(indexPath : IndexPath, collectionView : UICollectionView) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifiers.webAlbumCell, for: indexPath) as? WebAlbumCell {

            cell.styleLayout()
            let item = listAlbum[indexPath.row]
            cell.configure(album: item)

            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func selectCollectionViewCell(indexPath: IndexPath) {
        let selectedAlbum = listAlbum[indexPath.row]
        let subtype = MediaLibrary.getSubTypeOfFile(filename: self.filename!)
        if subtype == "gif" {
            uploadGifImageToAlbum(data: self.dataImage!, filename: nil, album: selectedAlbum)
        } else {
            uploadImageToAlbum(selectedAlbum: selectedAlbum)
        }
    }
    
    func setImageDownload(data: Data, filename: String) {
        self.dataImage = data
        self.filename = filename
    }
    
    func setAlbum(album: Album) {
        self.album = album
    }
    
    func getListAlbum() {
        self.listAlbum = AlbumManager.shared.getAlbums()
    }
    
    func getAlbumDownloads() {
        var downloadAlbum: Album?
        downloadAlbum = AlbumManager.shared.getAlbum(title: "Downloads")
        if let temp = downloadAlbum {
            setAlbum(album: temp)
        } else {
            setAlbum(album: AlbumManager.shared.addAlbum(title: "Downloads"))
        }
    }
    
    func uploadImageToDownloadAlbum(image: UIImage, filename: String) {

        let fileManager = FileManager.default
        let currentIndex = Int(album.currentIndex)

        let subtype = MediaLibrary.getSubTypeOfFile(filename: filename)
        let filename = String.init(format: "IMAGE_%i", currentIndex) + "." + subtype
        let thumbname = "thumbnail" + "_" + filename
        let directoryName = album.directoryName
        
        // Add image to DB
        let info: [String: Any] = ["filename": filename, "thumbname": thumbname, "type": Key.ItemType.ImageType]
        ItemManager.shared.add(info: info, toAlbum: album)
        
        // Save original image
        let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(filename)
        if fileManager.fileExists(atPath: path.path) {
            print("===============")
            print("Image \(filename) exists")
        } else {
            if let data = image.pngData() {
                fileManager.createFile(atPath: path.path, contents: data, attributes: nil)
            }
        }
        
        // Save thumbnail image
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

        self.album.currentIndex = Int32(currentIndex + 1)
        CoreDataManager.shared.saveContext()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Key.SString.notiUpdateGallery), object: nil)
    
        print("===============")
        print("Upload image success")
    }
    
    func uploadImageToAlbum(selectedAlbum: Album) {
        
        if let data = self.dataImage, let name = self.filename {
            let image = UIImage(data: data)!
            
            let fileManager = FileManager.default
            let currentIndex = Int(selectedAlbum.currentIndex)
            
            let subtype = MediaLibrary.getSubTypeOfFile(filename: name)
            let filename = String.init(format: "IMAGE_%i", currentIndex) + "." + subtype
            let thumbname = "thumbnail" + "_" + filename
            let directoryName = selectedAlbum.directoryName
            
            // Add image to DB
            let info: [String: Any] = ["filename": filename, "thumbname": thumbname, "type": Key.ItemType.ImageType]
            ItemManager.shared.add(info: info, toAlbum: selectedAlbum)
            
            // Save original image
            let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(filename)
            if fileManager.fileExists(atPath: path.path) {
                print("===============")
                print("Image \(filename) exists")
            } else {
                if let data = image.pngData() {
                    fileManager.createFile(atPath: path.path, contents: data, attributes: nil)
                }
            }
            
            // Save thumbnail image
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
            
            selectedAlbum.currentIndex = Int32(currentIndex + 1)
            CoreDataManager.shared.saveContext()
            
            self.dataImage = nil
            self.filename = nil
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Key.SString.notiUpdateGallery), object: nil)
            
            print("===============")
            print("Upload image success")
        }
    }
    
    func uploadGifImageToAlbum(data: Data, filename: String?, album: Album?) {
        if let selectedAlbum = album  {
            let fileManager = FileManager.default
            let currentIndex = Int(selectedAlbum.currentIndex)
            
            let subtype = MediaLibrary.getSubTypeOfFile(filename: self.filename!)
            let filename = String.init(format: "IMAGE_%i", currentIndex) + "." + subtype
            let thumbname = "thumbnail" + "_" + filename
            let directoryName = selectedAlbum.directoryName
            
            // Add image to DB
            let info: [String: Any] = ["filename": filename, "thumbname": thumbname, "type": Key.ItemType.ImageType]
            ItemManager.shared.add(info: info, toAlbum: selectedAlbum)
            
            // Save original image
            let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(filename)
            if fileManager.fileExists(atPath: path.path) {
                print("===============")
                print("Image \(filename) exists")
            } else {
                fileManager.createFile(atPath: path.path, contents: data, attributes: nil)
            }
            
            // Save thumbnail image
            let thumbnailPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(thumbname)
            let thumbnailImage = MediaLibrary.getThumbnailImage(originalImage: UIImage(data: data)!)
            if fileManager.fileExists(atPath: thumbnailPath.path) {
                print("===============")
                print("Thumbnail \(thumbname) exists")
            } else {
                if let data = thumbnailImage.pngData() {
                    fileManager.createFile(atPath: thumbnailPath.path, contents: data, attributes: nil)
                }
            }
            
            selectedAlbum.currentIndex = Int32(currentIndex + 1)
            CoreDataManager.shared.saveContext()
        } else {
            let fileManager = FileManager.default
            let currentIndex = Int(self.album.currentIndex)
            
            let subtype = MediaLibrary.getSubTypeOfFile(filename: filename!)
            let filename = String.init(format: "IMAGE_%i", currentIndex) + "." + subtype
            let thumbname = "thumbnail" + "_" + filename
            let directoryName = self.album.directoryName
            
            // Add image to DB
            let info: [String: Any] = ["filename": filename, "thumbname": thumbname, "type": Key.ItemType.ImageType]
            ItemManager.shared.add(info: info, toAlbum: self.album)
            
            // Save original image
            let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(filename)
            if fileManager.fileExists(atPath: path.path) {
                print("===============")
                print("Image \(filename) exists")
            } else {
                fileManager.createFile(atPath: path.path, contents: data, attributes: nil)
            }
            
            // Save thumbnail image
            let thumbnailPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(thumbname)
            let thumbnailImage = MediaLibrary.getThumbnailImage(originalImage: UIImage(data: data)!)
            if fileManager.fileExists(atPath: thumbnailPath.path) {
                print("===============")
                print("Thumbnail \(thumbname) exists")
            } else {
                if let data = thumbnailImage.pngData() {
                    fileManager.createFile(atPath: thumbnailPath.path, contents: data, attributes: nil)
                }
            }
            
            self.album.currentIndex = Int32(currentIndex + 1)
            CoreDataManager.shared.saveContext()
        }

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Key.SString.notiUpdateGallery), object: nil)
        
        print("===============")
        print("Upload image success")
    }

    func uploadVideoToAlbum(url: URL, downloadUrl: URL) {
        let currentIndex = album.currentIndex
        let name = downloadUrl.lastPathComponent
        let subtype = MediaLibrary.getSubTypeOfFile(filename: name)
        let filename = String.init(format: "VIDEO_%i", currentIndex) + "." + subtype
        let directoryName = album.directoryName
        
        // Save original video
        let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(filename)
        
        UploadManager.shared.uploadVideo(videoPath: url, destinationPath: path) { (status) in
            if status {
                let thumbname = "thumbnail_" + String.init(format: "VIDEO_%i", currentIndex) + ".JPG"
                let asset : AVURLAsset = AVURLAsset(url: path, options: nil)
                let duration : CMTime = asset.duration
                
                // Get thumb image video
                var thumbImage = UIImage()
                let generator = AVAssetImageGenerator(asset: asset)
                do {
                    let frameRef = try generator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                    thumbImage = UIImage(cgImage: frameRef)
                } catch let error as NSError {
                    print("Error : \(error)")
                }
                
                // Thumbnail path
                let thumbPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(thumbname)
                
                // Save thumbnail
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: thumbPath.path) {
                    print("===============")
                    print("Thumbnail \(thumbPath.lastPathComponent) exists")
                } else {
                    if let data = thumbImage.pngData() {
                        fileManager.createFile(atPath: thumbPath.path, contents: data, attributes: nil)
                    }
                }
                
                // Add video to database
                let info: [String: Any] = ["filename": filename,
                                           "thumbname": thumbname,
                                           "type": Key.ItemType.VideoType,
                                           "duration": CMTimeGetSeconds(duration)]
                ItemManager.shared.add(info: info, toAlbum: self.album)
                
                DispatchQueue.main.async {
                    self.album.currentIndex = currentIndex + 1
                    CoreDataManager.shared.saveContext()
                    
                    print("===============")
                    print("Upload video success")
                }
            }
        }
    }    
}


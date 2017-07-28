//
//  WebViewModel.swift
//  PrivateCorner
//
//  Created by a on 7/26/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit

open class WebViewModel {
    
    fileprivate var album: Album
    fileprivate var listAlbum: [Album]
    fileprivate var imageDownload: UIImage?
    fileprivate var filename: String?
    
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
        uploadImageToAlbum(selectedAlbum: selectedAlbum)
    }
    
    func setImageDownload(image: UIImage, filename: String) {
        self.imageDownload = image
        self.filename = filename
    }
    
    func setAlbum(album: Album) {
        self.album = album
    }
    
    func getListAlbum() {
        self.listAlbum = AlbumManager.sharedInstance.getAlbums()
    }
    
    func getAlbumDownloads() {
        var downloadAlbum: Album?
        downloadAlbum = AlbumManager.sharedInstance.getAlbum(title: "Downloads")
        if let temp = downloadAlbum {
            setAlbum(album: temp)
        } else {
            setAlbum(album: AlbumManager.sharedInstance.addAlbum(title: "Downloads"))
        }
    }
    
    func uploadImageToDownloadAlbum(image: UIImage, filename: String) {

        let fileManager = FileManager.default
        let currentIndex = Int(album.currentIndex)

        let subtype = MediaLibrary.getSubTypeOfFile(filename: filename)
        let filename = String.init(format: "IMAGE_%i", currentIndex) + "." + subtype
        let thumbname = "thumbnail" + "_" + filename
        
        // Add image to DB
        let info: [String: Any] = ["filename": filename, "thumbname": thumbname, "type": Key.ItemType.ImageType]
        ItemManager.sharedInstance.add(info: info, toAlbum: album)
        
        // Save original image
        let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.name!).appendingPathComponent(filename)
        if fileManager.fileExists(atPath: path.path) {
            print("===============")
            print("Image \(filename) exists")
        } else {
            if let data = UIImagePNGRepresentation(image) {
                fileManager.createFile(atPath: path.path, contents: data, attributes: nil)
            }
        }
        
        // Save thumbnail image
        let thumbnailPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.name!).appendingPathComponent(thumbname)
        let thumbnailImage = MediaLibrary.getThumbnailImage(originalImage: image)
        if fileManager.fileExists(atPath: thumbnailPath.path) {
            print("===============")
            print("Thumbnail \(thumbname) exists")
        } else {
            if let data = UIImagePNGRepresentation(thumbnailImage) {
                fileManager.createFile(atPath: thumbnailPath.path, contents: data, attributes: nil)
            }
        }

        self.album.currentIndex = Int32(currentIndex + 1)
        CoreDataManager.sharedInstance.saveContext()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Key.String.notiUpdateGallery), object: nil)
    
        print("===============")
        print("Upload image success")
    }
    
    func uploadImageToAlbum(selectedAlbum: Album) {
        
        if let image = self.imageDownload, let name = self.filename {
            let fileManager = FileManager.default
            let currentIndex = Int(selectedAlbum.currentIndex)
            
            let subtype = MediaLibrary.getSubTypeOfFile(filename: name)
            let filename = String.init(format: "IMAGE_%i", currentIndex) + "." + subtype
            let thumbname = "thumbnail" + "_" + filename
            
            // Add image to DB
            let info: [String: Any] = ["filename": filename, "thumbname": thumbname, "type": Key.ItemType.ImageType]
            ItemManager.sharedInstance.add(info: info, toAlbum: selectedAlbum)
            
            // Save original image
            let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(selectedAlbum.name!).appendingPathComponent(filename)
            if fileManager.fileExists(atPath: path.path) {
                print("===============")
                print("Image \(filename) exists")
            } else {
                if let data = UIImagePNGRepresentation(image) {
                    fileManager.createFile(atPath: path.path, contents: data, attributes: nil)
                }
            }
            
            // Save thumbnail image
            let thumbnailPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(selectedAlbum.name!).appendingPathComponent(thumbname)
            let thumbnailImage = MediaLibrary.getThumbnailImage(originalImage: image)
            if fileManager.fileExists(atPath: thumbnailPath.path) {
                print("===============")
                print("Thumbnail \(thumbname) exists")
            } else {
                if let data = UIImagePNGRepresentation(thumbnailImage) {
                    fileManager.createFile(atPath: thumbnailPath.path, contents: data, attributes: nil)
                }
            }
            
            selectedAlbum.currentIndex = Int32(currentIndex + 1)
            CoreDataManager.sharedInstance.saveContext()
            
            self.imageDownload = nil
            self.filename = nil
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Key.String.notiUpdateGallery), object: nil)
            
            print("===============")
            print("Upload image success")
        }
    }
    
//    func uploadVideoToCoreData(video: Video, avasset: AVAsset, collectionView: UICollectionView) {
//        
//        if let avassetURL = avasset as? AVURLAsset {
//            let videoUrl = avassetURL.url
//            let name = avassetURL.url.lastPathComponent
//            let currentIndex = album.currentIndex
//            let subtype = MediaLibrary.getSubTypeOfFile(filename: name)
//            let filename = String.init(format: "VIDEO_%i", currentIndex) + "." + subtype
//            let thumbname = "thumbnail_" + String.init(format: "VIDEO_%i", currentIndex) + ".JPG"
//            
//            // Add video to database
//            let info: [String: Any] = ["filename": filename,
//                                       "thumbname": thumbname,
//                                       "type": Key.ItemType.VideoType,
//                                       "duration": video.duration]
//            ItemManager.sharedInstance.add(info: info, toAlbum: album)
//            
//            // Save original video & thumbnail
//            let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.name!).appendingPathComponent(filename)
//            let thumbPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.name!).appendingPathComponent(thumbname)
//            
//            UploadManager.sharedInstance.uploadVideo(video: video, videoPath: videoUrl, destinationPath: path, thumbPath: thumbPath, delegate: delegate, completion: { (status) in
//                if status {
//                    
//                    DispatchQueue.main.async {
//                        self.album.currentIndex = currentIndex + 1
//                        CoreDataManager.sharedInstance.saveContext()
//                        
//                        let oldItems = self.items
//                        self.items = ItemManager.sharedInstance.getItems(album: self.album)
//                        self.delegate?.reloadGallery()
//                        collectionView.animateItemChanges(oldData: oldItems, newData: self.items)
//                        self.updateSupplementaryElement(collectionView: collectionView)
//                        
//                        print("===============")
//                        print("Upload video success")
//                    }
//                }
//            })
//        }
//    }
    
}

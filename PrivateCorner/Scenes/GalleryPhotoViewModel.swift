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
import Diff

public protocol GalleryPhotoViewModelDelegate: class {

    func reloadGallery()
    func updateProgressRing(value: CGFloat)
}


open class GalleryPhotoViewModel {
    
    fileprivate var album: Album
    fileprivate var items = [Item]()
    var titleAlbum: String
    let kNumberOfSectionsInCollectionView = 1
    weak var delegate: GalleryPhotoViewModelDelegate?
    
    struct cellIdentifiers {
        static let galleryCell = "galleryCell"
    }
    
    struct cellLayout {
        static let itemsPerRow: CGFloat = 3
        static let cellSize: CGSize = CGSize(width: kScreenWidth/CGFloat(itemsPerRow),
                                             height: kScreenWidth/CGFloat(itemsPerRow))
    }

    // MARK: - Public Methods
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

    func photoViewModel() -> PhotoViewViewModel {
        return PhotoViewViewModel(items: items)
    }
    
    func numberOfItemInSection(section: Int) -> Int {
        return items.count
    }
    
    func numberOfSection() -> Int {
        return kNumberOfSectionsInCollectionView
    }
    
    func setUpCollectionViewCell(indexPath : IndexPath, collectionView : UICollectionView) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifiers.galleryCell, for: indexPath) as? GalleryCell {
            
            cell.styleUI()
            let item = items[indexPath.row]
            cell.setupData(item: item)
            
            cell.photoImageView.heroID = "image_\(indexPath.row)"
            cell.photoImageView.heroModifiers = [.fade, .scale(0.8)]
            cell.photoImageView.isOpaque = true
            
            cell.durationLabel.heroModifiers = [.fade]
            cell.shadowView.heroModifiers = [.fade]
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func cellSize() -> CGSize {
        return cellLayout.cellSize
    }
    
    func cellIdentifier() -> String {
        return cellIdentifiers.galleryCell
    }
    
    func uploadImageToCoreData(images: [UIImage], assets: [PHAsset]) {
        
        let filenames = fetchImages(assets)
        let group = DispatchGroup()
        let percent: CGFloat = 100 / CGFloat(images.count * 2)
        var currentPercent: CGFloat = 0
        let fileManager = FileManager.default

        for image in images {
            let index = images.index(of: image)
            let filename = filenames[index!]
            let thumbname = "thumbnail" + filename
            
            // Add image to DB
            let info: [String: Any] = ["filename": filename, "thumbname": thumbname, "type": Key.ItemType.ImageType]
            ItemManager.sharedInstance.add(media: image, info: info, toAlbum: album)
            
            // Save original image
            let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(filename)
            if fileManager.fileExists(atPath: path.path) {
                print("===============")
                print("Image \(filename) exists")
            } else {
                group.enter()
                if let data = UIImagePNGRepresentation(image) {

                    let success = fileManager.createFile(atPath: path.path, contents: data, attributes: nil)
                    if success {
                        group.leave()
                        currentPercent += percent
                        delegate?.updateProgressRing(value: currentPercent)
                    }
                }
            }
            
            // Save thumbnail image
            let thumbnailPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(thumbname)
            let thumbnailImage = MediaLibrary.getThumbnailImage(originalImage: image)
            if fileManager.fileExists(atPath: thumbnailPath.path) {
                print("===============")
                print("Thumbnail \(thumbname) exists")
            } else {
                group.enter()
                if let data = UIImagePNGRepresentation(thumbnailImage) {
                    let success = fileManager.createFile(atPath: thumbnailPath.path, contents: data, attributes: nil)
                    if success {
                        group.leave()
                        currentPercent += percent
                        delegate?.updateProgressRing(value: currentPercent)
                    }
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) { 
            self.getGallery()
            print("===============")
            print("Upload images success")
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
            let info: [String: Any] = ["filename": filename, "thumbname": thumbname, "type": Key.ItemType.VideoType]
            ItemManager.sharedInstance.add(media: video, info: info, toAlbum: album)
            
            // Save original video
            group.enter()
            let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(filename)
            if fileManager.fileExists(atPath: path.path) {
                print("===============")
                print("Video \(filename) exists")
            } else {
                
                saveVideoFile(videoUrl: videoUrl, destinationPath: path)
                group.leave()
                delegate?.updateProgressRing(value: 50)
            }
            
            // Save thumbnail video
            group.enter()
            let thumbnailPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(thumbname)
            video.fetchThumbnail(CGSize(width: 512, height: 512), completion: { (image) in
                if fileManager.fileExists(atPath: thumbnailPath.path) {
                    print("===============")
                    print("Thumbnail \(thumbname) exists")
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
                print("===============")
                print("Upload video success")
            })
        }
    }
    
    func deleteItem(indexes: [Int], collectionView: UICollectionView) {
        let fileManager = FileManager.default
        
        for index in indexes {
            let item = items[index]
            
            // Delete item from database
            ItemManager.sharedInstance.deleteItem(item: item, atAlbum: album)
            
            // Delete file of item in documents
            if let filename = item.fileName {
                let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(filename)
                do {
                    if fileManager.fileExists(atPath: path.path) {
                        try fileManager.removeItem(at: path)
                    } else {
                        print("===============")
                        print("File not exists")
                        print("Can't delete file : \(filename)")
                    }
                } catch {
                    print("===============")
                    print("Error remove item \(filename), \(error)")
                }
            }
            
            if let thumbname = item.thumbName {
                let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(thumbname)
                do {
                    if fileManager.fileExists(atPath: path.path) {
                        try fileManager.removeItem(at: path)
                    } else {
                        print("===============")
                        print("File not exists")
                        print("Can't delete file : \(thumbname)")
                    }
                } catch {
                    print("===============")
                    print("Error remove item \(thumbname), \(error)")
                }
            }
        }
        
        let indexesToRemove = Set(indexes.flatMap { $0 })
        let newItems = items.enumerated().filter { !indexesToRemove.contains($0.offset) }.map { $0.element }
        
        collectionView.animateItemChanges(oldData: items, newData: newItems)
        items = newItems
    }

    // MARK: Private Method
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

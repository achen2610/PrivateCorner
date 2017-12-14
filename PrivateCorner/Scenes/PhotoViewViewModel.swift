//
//  PhotoViewViewModel.swift
//  PrivateCorner
//
//  Created by a on 5/26/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import Photos
import Gifu

public protocol PhotoViewViewModelDelegate: class {

    func exportSuccess()
    func sendEmail(emailVC: MFMailComposeViewController)
    func copyImagesSuccess()
    func deleteSuccess()
}

open class PhotoViewViewModel {

    fileprivate var album = Album()
    fileprivate var items = [Item]()
    var isEndTransition: Bool = false
    weak var delegate: PhotoViewViewModelDelegate?
    
    public init(items: [Item], inAlbum album: Album) {
        self.items = items
        self.album = album
    }
    
    func numberOfItemInSection(section: Int) -> Int {
        return items.count
    }
    
    func configure(cell: Any, atIndex index: Int) {
        let item = items[index]
        
        if item.type == "image" {
            if let photoCell = cell as? PhotoCell {
                photoCell.imageView.prepareForReuse()
                
                guard let directoryName = album.directoryName else {
                    return
                }
                
                let urlPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(item.fileName!)
//                let ext = item.fileName!.components(separatedBy: ".").last
//                if ext == "gif" {
//                    do {
//                        let data = try Data(contentsOf: urlPath)
//                        photoCell.imageView.animate(withGIFData: data)
//                        
//                    } catch let error as NSError {
//                        print("Error \(error)")
//                    }
//                } else {
                photoCell.image = MediaLibrary.image(urlPath: urlPath)
//                }
            }
        } else {
            if let videoCell = cell as? VideoCell {
                guard let directoryName = album.directoryName else {
                    return
                }
                
                let urlPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(item.fileName!)
                videoCell.configureVideo(url: urlPath, isEndTransition: isEndTransition)
            }
        }
    }
    
    func getTypeItem(index: Int) -> String {
        let item = items[index]
        return item.type!
    }
    
    func getUploadDate(index: Int) -> [String] {
        let item = items[index]
        var title = [String]()
        if let uploadDate = item.uploadDate as Date? {
            let dateFormatter = DateFormatter()
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            dateFormatter.dateFormat = "MMM dd"
            let topText = dateFormatter.string(from: uploadDate)
            title.append(topText)
            
            dateFormatter.dateFormat = "h:mm a"
            let bottomText = dateFormatter.string(from: uploadDate)
            title.append(bottomText)
        }
        return title
    }
    
    func deleteItem(index: Int, collectionView: UICollectionView) {
        let fileManager = FileManager.default
        let item = items[index]
        
        guard let directoryName = album.directoryName else {
            return
        }
        
        // Delete item from database
        ItemManager.sharedInstance.deleteItem(item: item, atAlbum: album)
        
        // Delete file of item in documents
        if let filename = item.fileName {
            let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(filename)
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
            let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(thumbname)
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
        
        let oldItems = items
        items.remove(at: index)
        collectionView.animateItemChanges(oldData: oldItems, newData: items)
        
        delegate?.deleteSuccess()
    }
    
    func exportFile(index: Int, type: Key.ExportType) {
        let item = items[index]
        
        guard let directoryName = album.directoryName else {
            return
        }
        
        switch type {
        case .PhotoLibrary:
            let urlPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(item.fileName!)
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: MediaLibrary.image(urlPath: urlPath))
            }, completionHandler: { (success, error) in
                if success {
                    // Saved successfully!
                    self.delegate?.exportSuccess()
                    print("Export \(item.fileName!) success")
                }
                else if error != nil {
                    // Save photo failed with error
                    
                    print("Export \(item.fileName!) error: \(error!)")
                }
                else {
                    // Save photo failed with no error
                }
            })
            break
        case .Email:
            let composeVC = MFMailComposeViewController()
            let urlPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(item.fileName!)
            let ext = item.fileName!.components(separatedBy: ".").last?.lowercased()
            do {
                let fileData = try Data(contentsOf: urlPath)
                composeVC.addAttachmentData(fileData, mimeType: String.init(format: "image/%@", ext!), fileName: item.fileName!)
            }
            catch {
                print("\(error.localizedDescription)")
            }
            delegate?.sendEmail(emailVC: composeVC)
            
            break
        case .Copy:
            let info: [String: Any] = ["album": album.objectID.uriRepresentation(),
                                       "items": [item.objectID.uriRepresentation()]]
            let data = NSKeyedArchiver.archivedData(withRootObject: info)
            UserDefaults.standard.set(data, forKey: "ItemCopy")
            UserDefaults.standard.synchronize()
            delegate?.copyImagesSuccess()
            
            break
        }
    }
}


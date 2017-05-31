//
//  PhotoViewViewModel.swift
//  PrivateCorner
//
//  Created by a on 5/26/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit

open class PhotoViewViewModel {

    var items = [Item]()
    
    public init(items: [Item]) {
        self.items = items
    }
    
    func countPhoto() -> Int {
        return items.count
    }
    
    func configure(cell: Any, atIndex index: Int) {
        let item = items[index]
        
        if item.type == "image" {
            if let photoCell = cell as? PhotoCell {
                let urlPath = getDocumentsDirectory().appendingPathComponent(item.fileName!)
                photoCell.image = MediaLibrary.image(urlPath: urlPath)
            }
        } else {
            if let videoCell = cell as? VideoCell {
                let urlPath = getDocumentsDirectory().appendingPathComponent(item.fileName!)
                videoCell.configureVideo(url: urlPath)
                videoCell.playVideo()
            }
        }

//        cell.imageFromUrl(urlPath: urlPath)
        
//        ImageLibrary.getDataFromUrl(url: urlPath) { (data, urlResponse, error) in
//            guard let data = data, error == nil else { return }
//            print(urlResponse?.suggestedFilename ?? urlPath.lastPathComponent)
//            print("Download Finished")
//            DispatchQueue.main.async() { () -> Void in
//                cell.image = UIImage(data: data)
//            }
//            
//        }
    }
    
    func getTypeItem(index: Int) -> String {
        let item = items[index]
        return item.type!
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
}

extension PhotoCell {
    public func imageFromUrl(urlPath: URL) {
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: urlPath) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
    }
}


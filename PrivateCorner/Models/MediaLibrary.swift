//
//  ImageLibrary.swift
//  PrivateCorner
//
//  Created by a on 5/29/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit
import Photos

class MediaLibrary {
    static func image(urlPath: URL) -> UIImage {
        return UIImage(contentsOfFile: urlPath.path) ?? UIImage(named: "noimagefound.png")!
    }
    
    static func getThumbnailImage(originalImage: UIImage) -> UIImage {
        var width: CGFloat = 256
        var height: CGFloat = 256
        let originalSize = originalImage.size
        if originalSize.width > originalSize.height {
            height = width * originalSize.height / originalSize.width
        } else {
            width = height * originalSize.width / originalSize.height
        }
        
        let destinationSize = CGSize(width: width, height: height)
        var newImage: UIImage
        
        UIGraphicsBeginImageContext(destinationSize)
        originalImage.draw(in: CGRect(x: 0, y: 0, width: destinationSize.width, height: destinationSize.height))
        newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    static func fetchImages(_ assets: [PHAsset]) -> [String] {
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
    
    static func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    

    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func getSubTypeOfFile(filename: String) -> String {
        var subtype: String
        let array = filename.components(separatedBy: ".")
        subtype = array.last ?? ""
        return subtype
    }
}

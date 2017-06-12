//
//  ImageLibrary.swift
//  PrivateCorner
//
//  Created by a on 5/29/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class MediaLibrary {
    static func image(urlPath: URL) -> UIImage {
        return UIImage(contentsOfFile: urlPath.path)!
    }
    
    static func getThumbnailImage(originalImage: UIImage) -> UIImage {
        var width: CGFloat = 512
        var height: CGFloat = 512
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
    
}

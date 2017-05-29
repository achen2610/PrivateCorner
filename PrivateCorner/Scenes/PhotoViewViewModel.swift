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

    var urlPaths = [URL]()
    
    public init(urlPaths: [URL]) {
        self.urlPaths = urlPaths
    }
    
    func countPhoto() -> Int {
        return urlPaths.count
    }
    
    func configure(cell: PhotoCell, atIndex index: Int) {
        let urlPath = urlPaths[index]
        cell.image = ImageLibrary.image(urlPath: urlPath)
        
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


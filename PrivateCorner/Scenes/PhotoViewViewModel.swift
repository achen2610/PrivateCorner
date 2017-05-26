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

    var photos = [INSPhotoViewable]()
    
    public init(photos: [INSPhotoViewable]) {
        self.photos = photos
    }
    
    func countPhoto() -> Int {
        return photos.count
    }
    
    func configure(cell: PhotoCell, atIndex index: Int) {
        let photo = photos[index]
        photo.loadImageWithCompletionHandler { [weak photo](image, error) in
            if let image = image {
                if let photo = photo as? INSPhoto {
                    photo.image = image
                }
                cell.image = image
            }
        }
    }
}

//
//  GalleryCell.swift
//  PrivateCorner
//
//  Created by a on 3/30/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit
import SDWebImage

class GalleryCell: UICollectionViewCell {
    
    static var documentsDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }()
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(photo: INSPhotoViewable) {
        
        photo.loadImageWithCompletionHandler { [weak photo](image, error) in
            if let image = image {
                if let photo = photo as? INSPhoto {
                    photo.image = image
                }
                self.photoImageView.image = image
            }
        }
    }

}

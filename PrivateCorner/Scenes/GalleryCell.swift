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
    
    func configure(item: Item) {
        
        if let filename = item.filename {
            let path = GalleryCell.documentsDirectory.appendingPathComponent(filename)
           
            photoImageView.sd_setImage(with: path, placeholderImage: UIImage(), options: [], completed: { (image, error, cacheType, imageURL) in
                self.photoImageView.alpha = 0.0
                UIView.animate(withDuration: 1.0, animations: {
                    self.photoImageView.alpha = 1.0
                })
            })
        }
        
    }

}

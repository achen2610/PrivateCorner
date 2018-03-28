//
//  AddFileCell.swift
//  PrivateCorner
//
//  Created by a on 6/13/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit
import SDWebImage

class MoveFileCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var albumName: UITextField!
    @IBOutlet weak var totalItem: UILabel!
    @IBOutlet weak var transparentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureLayout() {
        photoImageView.layer.cornerRadius = 5.0
        transparentView.layer.cornerRadius = 5.0
        transparentView.isHidden = true
    }
    
    func configure(album: Album) {
        albumName.text = album.name

        let array = ItemManager.sharedInstance.getItems(album: album)
        let lastImage = array.first
        
        if let filename = lastImage?.fileName {
            if let directoryName = album.directoryName {
                let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(directoryName).appendingPathComponent(filename)
                
                photoImageView.sd_setImage(with: path, placeholderImage: UIImage(), options: [], completed: { (image, error, cacheType, imageURL) in
                    
                })
            } else {
                let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.name!).appendingPathComponent(filename)
                
                photoImageView.sd_setImage(with: path, placeholderImage: UIImage(), options: [], completed: { (image, error, cacheType, imageURL) in
                    
                })
            }
        }
        
        totalItem.text = "\(array.count)"
    }
}


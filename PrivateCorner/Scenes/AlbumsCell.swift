//
//  AlbumsCell.swift
//  PrivateCorner
//
//  Created by a on 3/16/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit
import SDWebImage

class AlbumsCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var albumName: UITextField!
    @IBOutlet weak var totalItem: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureLayout() {
        photoImageView.layer.cornerRadius = 5.0
    }
    
    func configure(album: Album) {
        albumName.text = album.name
        
        let array = ItemManager.sharedInstance.getItems(album: album)
        let lastImage = array.first
        
        if let filename = lastImage?.fileName {
            let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.directoryName!).appendingPathComponent(filename)
            
            photoImageView.sd_setImage(with: path, placeholderImage: UIImage(), options: [], completed: { (image, error, cacheType, imageURL) in
//                self.photoImageView.alpha = 0.0
//                UIView.animate(withDuration: 1.0, animations: {
//                    self.photoImageView.alpha = 1.0
//                })
            })
        }
        
        totalItem.text = "\(array.count)"
    }
    
    func setEditMode(isEdit: Bool) {
        UIView.transition(with: deleteButton, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.deleteButton.isHidden = !isEdit
            self.albumName.isEnabled = isEdit
            self.totalItem.isUserInteractionEnabled = isEdit
            self.photoImageView.isUserInteractionEnabled = isEdit
        }, completion: nil)
    }
}

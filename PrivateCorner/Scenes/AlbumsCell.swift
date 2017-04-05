//
//  AlbumsCell.swift
//  PrivateCorner
//
//  Created by a on 3/16/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class AlbumsCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var totalItem: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureLayout() {
//        contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
//        albumName.preferredMaxLayoutWidth = 50
        photoImageView.layer.cornerRadius = 5.0
    }
    
    func configure(forAlbum album:Album) {
        albumName.text = album.name
        totalItem.text = "\(album.totalItem)"
        
//        if let URL = NSURL(string: album.imageURLString) {
//            photoImageView.kf_setImageWithURL(URL)
//        }
    }
}

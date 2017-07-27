//
//  AlbumCell.swift
//  PrivateCorner
//
//  Created by a on 7/27/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit
import SDWebImage

class WebAlbumCell: UICollectionViewCell {

    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func styleLayout() {
        albumImageView.layer.cornerRadius = 5.0
    }
    
    func configure(album: Album) {
        nameLabel.text = album.name
        
        let array = ItemManager.sharedInstance.getItems(album: album)
        if array.count > 0 {
            let lastItem = array.last
            
            if let thumbname = lastItem?.thumbName {
                let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.name!).appendingPathComponent(thumbname)
                albumImageView.image = MediaLibrary.image(urlPath: path)
            }
        } else {
            albumImageView.image = UIImage(named: "albums.png")
        }
    }
}

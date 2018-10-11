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
    @IBOutlet weak var backgroundName: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func styleLayout() {
        self.layoutIfNeeded()
        
        albumImageView.layer.cornerRadius = 5.0
        
        let path = UIBezierPath(roundedRect:backgroundName.bounds,
                                byRoundingCorners: [.bottomRight, .bottomLeft],
                                cornerRadii: CGSize(width: 5, height: 5))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = backgroundName.bounds
        maskLayer.path = path.cgPath
        backgroundName.layer.mask = maskLayer
    }
    
    func configure(album: Album) {
        nameLabel.text = album.name
        
        let array = ItemManager.shared.getItems(album: album)
        if array.count > 0 {
            let lastItem = array.last
            
            if let thumbname = lastItem?.thumbName {
                let path = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.directoryName).appendingPathComponent(thumbname)
                albumImageView.image = MediaLibrary.image(urlPath: path)
            }
        } else {
            albumImageView.image = UIImage(named: "albums.png")
        }
    }
}

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
        totalItem.text = "\(album.totalItem)"
        
//        if let URL = NSURL(string: album.imageURLString) {
//            photoImageView.kf_setImageWithURL(URL)
//        }
    }
    
    func setEditMode(isEdit: Bool) {
        UIView.transition(with: deleteButton, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.deleteButton.isHidden = !isEdit
            self.albumName.isEnabled = isEdit
        }, completion: nil)
    }
}

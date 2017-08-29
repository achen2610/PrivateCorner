//
//  ChooseAlbumCell.swift
//  PrivateCorner
//
//  Created by a on 8/29/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit
import SDWebImage

class ChooseAlbumCell: UICollectionViewCell {
    
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
}

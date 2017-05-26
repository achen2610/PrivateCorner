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
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var isEdit: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override var isSelected: Bool {
        didSet {
            if isEdit {
                self.backgroundImageView.backgroundColor = isSelected ? UIColor.black : UIColor.clear
                self.backgroundImageView.alpha = isSelected ? 0.2 : 1.0
            }
        }
    }
}

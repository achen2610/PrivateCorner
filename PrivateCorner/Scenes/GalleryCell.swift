//
//  GalleryCell.swift
//  PrivateCorner
//
//  Created by a on 3/30/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
    func styleUI() {
        if let subLayers = shadowView.layer.sublayers {
            for layer in subLayers {
                layer.removeFromSuperlayer()
            }
        }
        
        let gradient = CAGradientLayer.init()
        gradient.frame = shadowView.bounds;
        gradient.colors = [UIColor.init(red: 0, green: 0, blue: 0, alpha: 0).cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor]
        shadowView.layer.insertSublayer(gradient, at: 0)
        
        containerView.backgroundColor = UIColor.black
        containerView.alpha = 0.6
    }

//    override var isSelected: Bool {
//        didSet {
//            self.backgroundImageView.backgroundColor = isSelected ? UIColor.black : UIColor.clear
//            self.backgroundImageView.alpha = isSelected ? 0.6 : 1.0
//        }
//    }
}

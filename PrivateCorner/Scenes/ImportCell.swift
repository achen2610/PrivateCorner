//
//  ImportCell.swift
//  PrivateCorner
//
//  Created by a on 3/30/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class ImportCell: UICollectionViewCell {

    @IBOutlet weak var importBtn: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func centerButtonImageAndTitle() {
        let spacing: CGFloat = 0
        let titleSize = importBtn.titleLabel!.frame.size
        let imageSize = importBtn.imageView!.frame.size
        
//        importBtn.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: -imageSize.width/2, bottom: 0, right: -titleSize.width)
//        importBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0)
        
    }
}

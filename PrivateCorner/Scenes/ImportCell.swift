//
//  ImportCell.swift
//  PrivateCorner
//
//  Created by a on 3/30/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class ImportCell: UITableViewCell {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func configureCell(indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            photoView.image = UIImage(named: "photolibrary")
            titleLabel.text = "Photo Library"
            break
        case 1:
            photoView.image = UIImage(named: "camera")
            titleLabel.text = "Camera"
            break
        case 2:
            photoView.image = UIImage(named: "itunes")
            titleLabel.text = "iTunes Syncing"
            break
        case 3:
            photoView.image = UIImage(named: "wireless")
            titleLabel.text = "Wireless Syncing"
            break
        default:
            break
        }
    }
}

//
//  SettingIndicatorCell.swift
//  PrivateCorner
//
//  Created by a on 8/18/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class SettingIndicatorCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first
        let location = touch?.location(in: self)
        if containerView.frame.contains(location!) {
            containerView.backgroundColor = UIColor(hex: "#2269AE")
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        let touch = touches.first
        let location = touch?.location(in: self)
        if containerView.frame.contains(location!) {
            containerView.backgroundColor = UIColor(hex: "#3398FB")
        }
    }
}

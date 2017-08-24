//
//  PCButton.swift
//  PrivateCorner
//
//  Created by a on 8/24/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit

class PCButton: UIButton {
    
    var highLightColor: UIColor?
    var notHighLightColor: UIColor?
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                if let highLightColor = highLightColor {
                    backgroundColor = highLightColor
                }
            } else {
                if let notHighLightColor = notHighLightColor {
                    backgroundColor = notHighLightColor
                } else {
                    backgroundColor = UIColor(hex: "#3398FB")
                }
            }
        }
    }
    
    
}

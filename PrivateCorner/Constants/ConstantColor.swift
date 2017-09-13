//
//  ConstantColor.swift
//  PrivateCorner
//
//  Created by a on 5/23/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit

enum AppColor {
    // Background
    case background
    
    // Blue
    case blue
    
    // Title color
    case title
    
    func getColor() -> UIColor {
        switch self {
        case .background:
            return UIColor.white
            
        case .blue:
            return UIColor(hex: "#3398FB")
            
        case .title:
            return UIColor.white
        }
    }
}


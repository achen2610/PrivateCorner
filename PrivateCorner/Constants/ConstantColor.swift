//
//  ConstantColor.swift
//  PrivateCorner
//
//  Created by a on 5/23/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit

enum ElementColor {
    // Background
    case background
    
    // Bar
    case bar
    
    // Title color
    case title
    
    func getColor() -> UIColor {
        switch self {
        case .background:
            return UIColor.white
            
        case .bar:
            return UIColor.white
            
        case .title:
            return UIColor(hex: "#3398FB")
        }
    }
}

enum AppColor {
    
    case blue
    case white
    case black
    
    func getColor() -> UIColor {
        switch self {
        case .blue:
            return UIColor(hex: "#3398FB")
        case .white:
            return UIColor.white
        case .black:
            return UIColor.black
        }
    }
    
}


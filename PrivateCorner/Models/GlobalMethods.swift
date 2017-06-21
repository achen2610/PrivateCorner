//
//  GlobalMethods.swift
//  PrivateCorner
//
//  Created by a on 6/21/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit

class GlobalMethods {

    static func alertController(title: String?, message: String?, cancelTitle: String?) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        return alertController
    }
    
}

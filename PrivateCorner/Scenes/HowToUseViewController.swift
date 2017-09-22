//
//  HowToUseViewController.swift
//  PrivateCorner
//
//  Created by a on 8/25/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class HowToUseViewController: UITableViewController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Key.Screen.howToUse
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppUtility.lockOrientation(.portrait)
    }
    
    // MARK: Event handling
    
    
}

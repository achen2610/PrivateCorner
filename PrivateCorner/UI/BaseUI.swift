//
//  BaseUI.swift
//  PrivateCorner
//
//  Created by a on 9/21/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    
    // MARK: Object lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Lock orientation portrait
        AppUtility.lockOrientation(.portrait)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

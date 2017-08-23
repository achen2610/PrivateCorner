//
//  PasscodeViewController.swift
//  PrivateCorner
//
//  Created by a on 8/22/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class PasscodeViewController: UIViewController {
    
    @IBOutlet weak var passcodeTable: UITableView!
    
    struct cellIdentifiers {
        static let passcodeCellA    = "PasscodeCellA"
        static let passcodeCellB    = "PasscodeCellB"
        static let passcodeCellC    = "PasscodeCellC"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Key.Screen.passcodeScreen
    }
    
}

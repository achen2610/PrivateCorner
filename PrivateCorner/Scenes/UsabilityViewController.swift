//
//  UsabilityViewController.swift
//  PrivateCorner
//
//  Created by a on 8/22/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class UsabilityViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    // MARK: Object lifecycle
    
    struct cellIdentifiers {
        static let usabilityCell    = "UsabilityCell"
    }
    
    var array = ["Enable TouchID", ""]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Key.Screen.usabilityScreen
        configureTableViewOnLoad()
    }
    
    // MARK: Event handling
    
    func configureTableViewOnLoad() {
        let nibName = UINib(nibName: "UsabilityCell", bundle:Bundle.main)
        tableView.register(nibName, forCellReuseIdentifier: cellIdentifiers.usabilityCell)
    }
}

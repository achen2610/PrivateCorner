//
//  SettingViewController.swift
//  PrivateCorner
//
//  Created by a on 3/15/17.
//  Copyright (c) 2017 MrAChen. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var settingTable: UITableView!
    // MARK: Object lifecycle
    
    struct cellIdentifiers {
        static let settingDetailCell    = "SettingDetailCell"
        static let settingIndicatorCell = "SettingIndicatorCell"
    }
    
    var array = [["", ["Version", "1.0"]],
                 ["", "Passcode", "Usability","How to use"],
                 ["", ["Author", "MrAchen"]]]

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableViewOnLoad()
    }
    
    // MARK: Event handling
    
    func configureTableViewOnLoad() {
        var nibName = UINib(nibName: "SettingDetailCell", bundle:Bundle.main)
        settingTable.register(nibName, forCellReuseIdentifier: cellIdentifiers.settingDetailCell)
        nibName = UINib(nibName: "SettingIndicatorCell", bundle:Bundle.main)
        settingTable.register(nibName, forCellReuseIdentifier: cellIdentifiers.settingIndicatorCell)
    }
    
    func selectedSettingAtIndex(index: Int) {
        
        if index == 0 {
            //Usability
        } else if index == 1 {
            //Passcode
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.backToLockScreenWhenChangePass()
            
        } else if index == 2 {
            //How to use
        }
    }

    
}


//
//  SettingTableViewController.swift
//  PrivateCorner
//
//  Created by a on 3/29/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

extension SettingViewController : UITableViewDataSource, UITableViewDelegate {
    
    // MARK: UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers.settingCell, for: indexPath) as? SettingCell {
            cell.titleLabel.text = "Setting \(indexPath.row)"
            
            return cell
        }
        
        return UITableViewCell()
    }

    // MARK: UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSettingAtIndex(index: indexPath.row)
    }
}

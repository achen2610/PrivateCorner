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
    func numberOfSections(in tableView: UITableView) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array[section].count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let string = array[indexPath.section][indexPath.row + 1] as? String {
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers.settingIndicatorCell, for: indexPath) as? SettingIndicatorCell {
                cell.titleLabel.text = string
                
                if indexPath.section == 0 || indexPath.section == 2 {
                    cell.selectionStyle = .none
                }
                
                return cell
            }
        }
        if let array = array[indexPath.section][indexPath.row + 1] as? [Any] {
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers.settingDetailCell, for: indexPath) as? SettingDetailCell {
                cell.titleLabel.text = array[0] as? String
                cell.detailLabel.text = array[1] as? String
                
                if indexPath.section == 0 || indexPath.section == 2 {
                    cell.selectionStyle = .none
                }
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44 * kScale
    }

    // MARK: UITableView Delegate    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 || indexPath.section == 2 {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! SettingIndicatorCell
        if cell.containerView.backgroundColor == UIColor(hex: "#2269AE") {
            UIView.animate(withDuration: 1.0) {
                cell.containerView.backgroundColor = UIColor(hex: "#3398FB")
            }
        }
        
        selectedSettingAtIndex(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: cell.separatorInset)) {
            cell.separatorInset = UIEdgeInsets.zero
        }
        
        if cell.responds(to: #selector(setter: cell.layoutMargins)) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
        
        if cell.responds(to: #selector(setter: cell.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
    }
}

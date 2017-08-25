//
//  PasscodeTableView.swift
//  PrivateCorner
//
//  Created by a on 8/22/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

extension PasscodeViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers.passcodeCellA, for: indexPath)
            
            let switchControl: UISwitch = cell.viewWithTag(81) as! UISwitch
            switchControl.addTarget(self, action: #selector(switchChanged(sender:)), for: .valueChanged)
            let enablePasswordRecovery = UserDefaults.standard.bool(forKey: Key.UserDefaults.enablePasswordRecovery)
            if !enablePasswordRecovery {
                switchControl.isOn = false
            } else {
                switchControl.isOn = true
            }
            
            return cell

        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers.passcodeCellB, for: indexPath)
            
            let switchControl: UISwitch = cell.viewWithTag(82) as! UISwitch
            switchControl.addTarget(self, action: #selector(switchChanged(sender:)), for: .valueChanged)
            let enableTouchID = UserDefaults.standard.bool(forKey: Key.UserDefaults.enableTouchID)
            if !enableTouchID {
                switchControl.isOn = false
            } else {
                switchControl.isOn = true
            }
            
            return cell

        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers.passcodeCellC, for: indexPath)
            
            let button: PCButton = cell.viewWithTag(80) as! PCButton
            button.highLightColor = UIColor(hex: "#2269AE")
            button.notHighLightColor = UIColor(hex: "#3398FB")
            button.setTitleColor(UIColor.white, for: [.normal, .highlighted, .selected])
            button.addTarget(self, action: #selector(clickedChangePasscodeButton), for: .touchUpInside)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 1 {
            return 44 * kScale
        } else {
            return 80
        }
    }
    
}

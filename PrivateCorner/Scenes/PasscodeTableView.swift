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
            return cell

        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers.passcodeCellB, for: indexPath)
            return cell

        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers.passcodeCellC, for: indexPath)
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

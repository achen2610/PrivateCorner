//
//  UsabilityTableView.swift
//  PrivateCorner
//
//  Created by a on 8/22/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

extension UsabilityViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers.usabilityCell, for: indexPath) as? UsabilityCell {
            cell.titleLabel.text = ""
            cell.selectionStyle = .none
            return cell
            }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44 * kScale
    }
    
}

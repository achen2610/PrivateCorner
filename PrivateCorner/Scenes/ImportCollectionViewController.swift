//
//  ImportCollectionViewController.swift
//  PrivateCorner
//
//  Created by a on 3/31/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

extension ImportViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers.importCell, for: indexPath) as? ImportCell {
            cell.configureCell(indexPath: indexPath)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedImportDetailAtIndex(index: indexPath.row)
    }
}

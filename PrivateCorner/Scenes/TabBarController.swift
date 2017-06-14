//
//  TabBarController.swift
//  PrivateCorner
//
//  Created by a on 5/18/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let tabBar = self.tabBar
        let tabBarAlbumItem = tabBar.items?[0]
        let tabBarImportItem = tabBar.items?[1]
        let tabBarSettingItem = tabBar.items?[2]
        
        tabBarAlbumItem?.image = UIImage.init(named: "folder.png")?.withRenderingMode(.alwaysOriginal)
        tabBarAlbumItem?.selectedImage = UIImage.init(named: "folder-on.png")?.withRenderingMode(.alwaysOriginal)
        
        tabBarImportItem?.image = UIImage.init(named: "import.png")?.withRenderingMode(.alwaysOriginal)
        tabBarImportItem?.selectedImage = UIImage.init(named: "import-on.png")?.withRenderingMode(.alwaysOriginal)
        
        tabBarSettingItem?.image = UIImage.init(named: "setting.png")?.withRenderingMode(.alwaysOriginal)
        tabBarSettingItem?.selectedImage = UIImage.init(named: "setting-on.png")?.withRenderingMode(.alwaysOriginal)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let controller = (tabBarController.selectedViewController as? UINavigationController)?.visibleViewController as? AlbumsViewController {
            if controller.isEditMode {
                controller.editAlbumButtonItemTapped((Any).self)
            }
        }
        
        return true
    }
}

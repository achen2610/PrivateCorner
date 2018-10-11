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
        let tabBarWebItem = tabBar.items?[2]
        let tabBarSettingItem = tabBar.items?[3]

//        tabBarAlbumItem?.title = nil
        tabBarAlbumItem?.image = UIImage.init(named: "album.png")
        tabBarAlbumItem?.selectedImage = UIImage.init(named: "album-on.png")
//        tabBarAlbumItem?.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)

        tabBarImportItem?.image = UIImage.init(named: "import.png")
        tabBarImportItem?.selectedImage = UIImage.init(named: "import-on.png")

        tabBarWebItem?.image = UIImage.init(named: "web.png")
        tabBarWebItem?.selectedImage = UIImage.init(named: "web-on.png")
        
        tabBarSettingItem?.image = UIImage.init(named: "setting.png")
        tabBarSettingItem?.selectedImage = UIImage.init(named: "setting-on.png")
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

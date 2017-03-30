//
//  LockScreenRouter.swift
//  PrivateCorner
//
//  Created by a on 3/9/17.
//  Copyright (c) 2017 MrAChen. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit

protocol LockScreenRouterInput {
    func navigateToHomeScreen()
}

protocol LockScreenRouterDataSource:class {
    
}

protocol LockScreenRouterDataDestination:class {
    
}

class LockScreenRouter: LockScreenRouterInput {
    
    weak var viewController:LockScreenViewController!
    weak private var dataSource:LockScreenRouterDataSource!
    weak var dataDestination:LockScreenRouterDataDestination!
    
    init(viewController:LockScreenViewController, dataSource:LockScreenRouterDataSource, dataDestination:LockScreenRouterDataDestination) {
        self.viewController = viewController
        self.dataSource = dataSource
        self.dataDestination = dataDestination
    }
    
    // MARK: Navigation
    func navigateToHomeScreen() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
        
        let tabBar = viewController.tabBar
        let tabBarAlbumItem = tabBar.items?[0]
        let tabBarImportItem = tabBar.items?[1]
        let tabBarSettingItem = tabBar.items?[2]
        
        tabBarAlbumItem?.image = UIImage.init(named: "folder.png")?.withRenderingMode(.alwaysOriginal)
        tabBarAlbumItem?.selectedImage = UIImage.init(named: "folder-on.png")?.withRenderingMode(.alwaysOriginal)
        
        tabBarImportItem?.image = UIImage.init(named: "import.png")?.withRenderingMode(.alwaysOriginal)
        tabBarImportItem?.selectedImage = UIImage.init(named: "import-on.png")?.withRenderingMode(.alwaysOriginal)
        
        tabBarSettingItem?.image = UIImage.init(named: "setting.png")?.withRenderingMode(.alwaysOriginal)
        tabBarSettingItem?.selectedImage = UIImage.init(named: "setting-on.png")?.withRenderingMode(.alwaysOriginal)
        
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    // MARK: Communication
    
    func passDataToNextScene(for segue: UIStoryboardSegue) {
        // NOTE: Teach the router which scenes it can communicate with
        
    }
}

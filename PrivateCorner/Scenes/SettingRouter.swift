//
//  SettingRouter.swift
//  PrivateCorner
//
//  Created by a on 3/15/17.
//  Copyright (c) 2017 MrAChen. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit

protocol SettingRouterInput {
    
}

protocol SettingRouterDataSource:class {
    
}

protocol SettingRouterDataDestination:class {
    
}

class SettingRouter: SettingRouterInput {
    
    weak var viewController:SettingViewController!
    weak private var dataSource:SettingRouterDataSource!
    weak var dataDestination:SettingRouterDataDestination!
    
    struct SegueIdentifiers {
        static let passwordScreen = "EditPassword"
    }
    
    init(viewController:SettingViewController, dataSource:SettingRouterDataSource, dataDestination:SettingRouterDataDestination) {
        self.viewController = viewController
        self.dataSource = dataSource
        self.dataDestination = dataDestination
    }
    
    // MARK: Navigation
    func navigateToPasswordScreen() {
        viewController.performSegue(withIdentifier: SegueIdentifiers.passwordScreen, sender: viewController)
    }
    
    // MARK: Communication
    
    func passDataToNextScene(for segue: UIStoryboardSegue) {
        // NOTE: Teach the router which scenes it can communicate with
        
    }
}
//
//  PhotoRouter.swift
//  PrivateCorner
//
//  Created by a on 3/16/17.
//  Copyright (c) 2017 MrAChen. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit

protocol PhotoRouterInput {
    
}

protocol PhotoRouterDataSource:class {
    
}

protocol PhotoRouterDataDestination:class {
    
}

class PhotoRouter: PhotoRouterInput {
    
    weak var viewController:PhotoViewController!
    weak private var dataSource:PhotoRouterDataSource!
    weak var dataDestination:PhotoRouterDataDestination!
    
    init(viewController:PhotoViewController, dataSource:PhotoRouterDataSource, dataDestination:PhotoRouterDataDestination) {
        self.viewController = viewController
        self.dataSource = dataSource
        self.dataDestination = dataDestination
    }
    
    // MARK: Navigation
    
    // MARK: Communication
    
    func passDataToNextScene(for segue: UIStoryboardSegue) {
        // NOTE: Teach the router which scenes it can communicate with
        
    }
}
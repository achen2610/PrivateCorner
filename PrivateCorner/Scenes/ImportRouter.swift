//
//  ImportRouter.swift
//  PrivateCorner
//
//  Created by a on 3/30/17.
//  Copyright (c) 2017 MrAChen. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit

protocol ImportRouterInput {
    
}

protocol ImportRouterDataSource:class {
    
}

protocol ImportRouterDataDestination:class {
    
}

class ImportRouter: ImportRouterInput {
    
    weak var viewController:ImportViewController!
    weak private var dataSource:ImportRouterDataSource!
    weak var dataDestination:ImportRouterDataDestination!
    
    init(viewController:ImportViewController, dataSource:ImportRouterDataSource, dataDestination:ImportRouterDataDestination) {
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

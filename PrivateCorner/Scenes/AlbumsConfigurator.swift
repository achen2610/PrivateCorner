//
//  AlbumsConfigurator.swift
//  PrivateCorner
//
//  Created by a on 3/15/17.
//  Copyright (c) 2017 MrAChen. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit

// MARK: Connect View, Interactor, and Presenter

extension AlbumsInteractor: AlbumsViewControllerOutput, AlbumsRouterDataSource, AlbumsRouterDataDestination {
}

extension AlbumsPresenter: AlbumsInteractorOutput {
}

class AlbumsConfigurator {
    // MARK: Object lifecycle
    
    static let sharedInstance = AlbumsConfigurator()
    
    private init() {}
    
    // MARK: Configuration
    
    func configure(viewController: AlbumsViewController) {
        
        let presenter = AlbumsPresenter()
        presenter.output = viewController
        
        let interactor = AlbumsInteractor()
        interactor.output = presenter
        
        let router = AlbumsRouter(viewController:viewController, dataSource:interactor, dataDestination:interactor)
        
        viewController.output = interactor
        viewController.router = router
    }
}

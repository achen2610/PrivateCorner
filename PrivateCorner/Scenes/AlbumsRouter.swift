//
//  AlbumsRouter.swift
//  PrivateCorner
//
//  Created by a on 3/15/17.
//  Copyright (c) 2017 MrAChen. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit

protocol AlbumsRouterInput {
    func navigateToGalleryScreen()
}

protocol AlbumsRouterDataSource:class {
    
}

protocol AlbumsRouterDataDestination:class {
    
}

class AlbumsRouter: AlbumsRouterInput {
    
    weak var viewController:AlbumsViewController!
    weak private var dataSource:AlbumsRouterDataSource!
    weak var dataDestination:AlbumsRouterDataDestination!
    
    struct SegueIdentifiers {
        static let galleryScreen = "ShowGallery"
        static let addAlbumScreen = "AddAlbum"
        static let editAlbumScreen = "EditAlbum"
    }
    
    init(viewController:AlbumsViewController, dataSource:AlbumsRouterDataSource, dataDestination:AlbumsRouterDataDestination) {
        self.viewController = viewController
        self.dataSource = dataSource
        self.dataDestination = dataDestination
    }
    
    // MARK: Navigation
    func navigateToGalleryScreen() {
        viewController.performSegue(withIdentifier: SegueIdentifiers.galleryScreen, sender: viewController)
    }
    
    func navigateToAddEditAlbumScreen(edit: Bool) {
        
        if edit {
            viewController.performSegue(withIdentifier: SegueIdentifiers.editAlbumScreen, sender: viewController)
        } else {
            viewController.performSegue(withIdentifier: SegueIdentifiers.addAlbumScreen, sender: viewController)
        }
    }
    
    // MARK: Communication
    
    func passDataToNextScene(for segue: UIStoryboardSegue) {
        // NOTE: Teach the router which scenes it can communicate with

        guard let segueIdentifier = segue.identifier else {
            return
        }
        
        switch segueIdentifier {
        case SegueIdentifiers.addAlbumScreen:
            if let addEditAlbumViewController = segue.destination as? AddEditAlbumViewController {
                addEditAlbumViewController.isEditAlbum = false
            }
        case SegueIdentifiers.editAlbumScreen:
            if let addEditAlbumViewController = segue.destination as? AddEditAlbumViewController {
                addEditAlbumViewController.isEditAlbum = true
            }
        default:
            return
        }
    }

}

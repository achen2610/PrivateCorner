//
//  AlbumsInteractor.swift
//  PrivateCorner
//
//  Created by a on 3/15/17.
//  Copyright (c) 2017 MrAChen. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit

protocol AlbumsInteractorInput {
    func getAlbum(request: AlbumsScene.GetAlbum.Request)
}

protocol AlbumsInteractorOutput {
    func presentAlbum(response:AlbumsScene.GetAlbum.Response)
}

protocol AlbumsDataSource {
    
}

protocol AlbumsDataDestination {
    
}

class AlbumsInteractor: AlbumsInteractorInput, AlbumsDataSource, AlbumsDataDestination {
    
    var output: AlbumsInteractorOutput!
    var selectedAlbum:Album!
    private var albums:[Album] = []
    
    // MARK: Business logic
    func getAlbum(request: AlbumsScene.GetAlbum.Request) {
        let result = AlbumManager.sharedInstance.getAlbums()
        handleGetAlbumResult(result: result)
    }
    
    private func handleGetAlbumResult(result: [Album]) {
        let response = AlbumsScene.GetAlbum.Response(albums: result)
        output.presentAlbum(response: response)
    }
    
    func selectAlbum(request:AlbumsScene.SelectAlbum.Request) {
        selectedAlbum = albums[request.index]
    }

}

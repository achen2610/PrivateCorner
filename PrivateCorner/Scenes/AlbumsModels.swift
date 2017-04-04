//
//  AlbumsModels.swift
//  PrivateCorner
//
//  Created by a on 3/15/17.
//  Copyright (c) 2017 MrAChen. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//
//  Type "usecase" for some magic!

import UIKit



struct AlbumsScene {
    
    struct GetAlbum {
        
        struct Request {
            
        }
        
        struct Response {
            let album:Album
        }
        
        struct ViewModel {
            let album:AlbumsScene.ViewModel.Album
        }
    }
    
    struct SelectAlbum {
        
        struct Request {
            let index:Int
        }
    }
    
    struct ViewModel {
        
        struct Album {
            let name:String
            let totalItem:Int
        }
        
    }
}

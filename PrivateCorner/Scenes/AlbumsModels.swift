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
            let albums:[Album]
        }
        
        struct ViewModel {
            let albums:[Album]
        }
    }
    
    struct SelectAlbum {
        
        struct Request {
            let index:Int
        }
    }
    
    struct AddAlbum  {
        struct Request {
            let title:String
        }
        
        struct Response {
            let album:Album
        }
        
        struct ViewModel {
            let album:Album
        }
    }
    
    struct DeleteAlbum  {
        struct Request {
            let album:Album
            let index:Int
        }
        
        struct Response {
            let index:Int
        }
    }
    
    struct ViewModel {

        
    }
}

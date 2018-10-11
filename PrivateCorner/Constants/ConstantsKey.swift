//
//  ConstantsKey.swift
//  PrivateCorner
//
//  Created by a on 4/3/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit

//FOR ALL THE KEYS USED IN APP

//KeyConstants.swift
struct Key {
    
    static let DeviceType = "iOS"
    struct Beacon{
        static let ONEXUUID = "xxxx-xxxx-xxxx-xxxx"
    }
    
    struct UserDefaults {
        static let k_App_Running_FirstTime          = "userRunningAppFirstTime"
        static let enableTouchID                    = "enableTouchID"
        static let enablePasswordRecovery           = "enablePasswordRecovery"
    }
    
    struct Headers {
        static let Authorization        = "Authorization"
        static let ContentType          = "Content-Type"
    }
    struct Google{
        static let placesKey            = "some key here"//for photos
        static let serverKey            = "some key here"
    }
    
    struct ErrorMessage{
        static let listNotFound         = "ERROR_LIST_NOT_FOUND"
        static let validationError      = "ERROR_VALIDATION"
    }
    
    struct SString {
        static let notiUpdateGalleryWhenMoveFile    = "notiUpdateGalleryWhenMoveFile"
        static let notiUpdateGallery                = "notiUpdateGallery"
        static let notiPerformSeguePasscodeView     = "notiPerformSeguePasscodeView"
        static let notiAlertChangePassSuccess       = "notiAlertChangePassSuccess"
    }
    
    struct Screen {
        static let album                            = "Albums"
        static let importPhoto                      = "Import"
        static let importWeb                        = "Web Server"
        static let setting                          = "Setting"
        static let privacy                          = "Privacy"
        static let usability                        = "Usability"
        static let howToUse                         = "How to use"
        static let moveFile                         = "Add photos to Album"
        static let chooseAlbum                      = "Choose album for import"
    }
    
    enum ItemType {
        case ImageType
        case VideoType
        
        func getType() -> String {
            var type: String = ""
            switch self {
            case .ImageType:
                type = "image"
                break
            case .VideoType:
                type = "video"
                break
            }
            return type
        }
    }
    
    enum ExportType {
        case PhotoLibrary
        case Email
        case Copy
    }
}

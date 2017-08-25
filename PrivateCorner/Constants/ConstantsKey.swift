//
//  ConstantsKey.swift
//  PrivateCorner
//
//  Created by a on 4/3/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation

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
    
    struct String {
        static let notiUpdateGalleryWhenMoveFile    = "notiUpdateGalleryWhenMoveFile"
        static let notiUpdateGallery                = "notiUpdateGallery"
        static let notiPerformSeguePasscodeView     = "notiPerformSeguePasscodeView"
        static let notiAlertChangePassSuccess       = "notiAlertChangePassSuccess"
    }
    
    struct Screen {
        static let albumScreen                      = "Albums"
        static let importScreen                     = "Import"
        static let settingScreen                    = "Setting"
        static let passcodeScreen                   = "Passcode"
        static let usabilityScreen                  = "Usability"
        static let howToUseScreen                   = "How to use"
    }
    
    enum ItemType {
        case ImageType
        case VideoType
    }
    
    enum ExportType {
        case PhotoLibrary
        case Email
        case Copy
    }
}

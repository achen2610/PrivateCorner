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
        static let k_App_Running_FirstTime = "userRunningAppFirstTime"
    }
    
    struct Headers {
        static let Authorization = "Authorization"
        static let ContentType = "Content-Type"
    }
    struct Google{
        static let placesKey = "some key here"//for photos
        static let serverKey = "some key here"
    }
    
    struct ErrorMessage{
        static let listNotFound = "ERROR_LIST_NOT_FOUND"
        static let validationError = "ERROR_VALIDATION"
    }
}

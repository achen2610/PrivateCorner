//
//  GalleryExtension.swift
//  PrivateCorner
//
//  Created by HungLe SoftFlight on 9/17/18.
//  Copyright © 2018 MrAChen. All rights reserved.
//

import UIKit
import Photos

extension GVideo {

    public func fetchDurationEx(_ completion: @escaping (Double) -> Void) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        
        let _ = PHImageManager.default().requestAVAsset(forVideo: asset, options: options) {
            asset, mix, _ in
            
            let duration = asset?.duration.seconds ?? 0
            DispatchQueue.main.async {
                completion(duration)
            }
        }
    }
}

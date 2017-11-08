//
//  MyWindow.swift
//  PrivateCorner
//
//  Created by a on 7/26/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit

class MyWindow: UIWindow {

    var tapLocation: CGPoint = CGPoint.zero
    var contextualMenuTimer: Timer? = Timer()
    
    @objc func tapAndHoldAction(timer: Timer) {
        contextualMenuTimer = nil
        var clickedView = self.hitTest(tapLocation, with: nil)
        while clickedView != nil {
            if clickedView is UIWebView {
                break
            }
            clickedView = clickedView?.superview
        }

        if (clickedView != nil) {
            let coord = ["x": tapLocation.x , "y": tapLocation.y]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TapAndHoldNotification"), object: coord)
        }
    }
    
    override func sendEvent(_ event: UIEvent) {
        let touches = event.touches(for: self)
        
        super.sendEvent(event)
        
        if touches?.count == 1 {// We're only interested in one-finger events
            if let touch = touches?.first {
                switch touch.phase {
                case .began: // A finger touched the screen
                    tapLocation = touch.location(in: self)
                    contextualMenuTimer?.invalidate()
                    contextualMenuTimer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(tapAndHoldAction(timer:)), userInfo: nil, repeats: false)
                    break
                case .ended, .moved, .cancelled:
                    contextualMenuTimer?.invalidate()
                    contextualMenuTimer = nil
                    break
                default:
                    break
                }
            }
        } else {
            contextualMenuTimer?.invalidate()
            contextualMenuTimer = nil
        }
    }
}

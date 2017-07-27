//
//  WebViewExtension.swift
//  PrivateCorner
//
//  Created by a on 7/26/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

extension UIWebView {
    func scrollOffset() -> CGPoint {
        var pt: CGPoint = CGPoint.zero
        if let n = NumberFormatter().number(from: self.stringByEvaluatingJavaScript(from: "window.pageXOffset")!) {
            pt.x = CGFloat(n)
        }
        if let n = NumberFormatter().number(from: self.stringByEvaluatingJavaScript(from: "window.pageYOffset")!) {
            pt.y = CGFloat(n)
        }
        return pt
    }
    
    func windowSize() -> CGSize {
        var size: CGSize = CGSize.zero
        if let n = NumberFormatter().number(from: self.stringByEvaluatingJavaScript(from: "window.innerWidth")!) {
            size.width = CGFloat(n)
        }
        if let n = NumberFormatter().number(from: self.stringByEvaluatingJavaScript(from: "window.innerHeight")!) {
            size.height = CGFloat(n)
        }
        return size
    }
}

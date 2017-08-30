//
//  ImportWebViewController.swift
//  PrivateCorner
//
//  Created by a on 8/30/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit

class ImportWebViewController: UIViewController {
    
    @IBOutlet weak var addressTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Key.Screen.importWeb
        
        WebServer.sharedInstance.delegate = self
        WebServer.sharedInstance.setDelegate()
        WebServer.sharedInstance.startServer()
        addressTextField.text = WebServer.sharedInstance.getAddress()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        WebServer.sharedInstance.stopServer()
    }
}

extension ImportWebViewController: WebServerDelegate {
    func webServerDidConnect(webServer: WebServer) {
        
    }
    
    func webServerDidUploadFile(webServer: WebServer, atPath path: String) {
        
    }
    
    func webServerDidDownloadFile(webServer: WebServer, atPath path: String) {
        
    }
    
    func webServerDidDisconnect(webServer: WebServer) {
        
    }
}

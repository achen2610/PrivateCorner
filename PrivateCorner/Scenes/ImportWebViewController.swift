//
//  ImportWebViewController.swift
//  PrivateCorner
//
//  Created by a on 8/30/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit

class ImportWebViewController: BaseViewController, ImportWebViewModelDelegate {
    
    @IBOutlet weak var addressTextField: UITextField!
    var viewModel: ImportWebViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Key.Screen.importWeb
        
        viewModel = ImportWebViewModel(delegate: self)
        
        WebServer.shared.delegate = self
        WebServer.shared.setDelegate()
        WebServer.shared.startServer()
        addressTextField.text = WebServer.shared.getAddress()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        WebServer.shared.stopServer()
    }
    
    // MARK: View Model Delegate
    
}

extension ImportWebViewController: WebServerDelegate {
    func webServerDidConnect(webServer: WebServer) {
        
    }
    
    func webServerDidUploadFile(webServer: WebServer, atPath path: String) {
        viewModel.saveFile(path: path) { (status) in
            if status {
                let alert = GlobalMethods.alertController(title: nil, message: "Save file to app success!", cancelTitle: "Ok")
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = GlobalMethods.alertController(title: nil, message: "Save file error!", cancelTitle: "Ok")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func webServerDidDownloadFile(webServer: WebServer, atPath path: String) {
        
    }
    
    func webServerDidDisconnect(webServer: WebServer) {
        
    }
}

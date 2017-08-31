//
//  WebServer.swift
//  PrivateCorner
//
//  Created by a on 8/30/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit
import GCDWebServer

public protocol WebServerDelegate: class {
    func webServerDidConnect(webServer: WebServer)
    func webServerDidUploadFile(webServer: WebServer, atPath path: String)
    func webServerDidDownloadFile(webServer: WebServer, atPath path: String)
    func webServerDidDisconnect(webServer: WebServer)
}

public class WebServer: NSObject  {
    
    // MARK: - Web Server stack
    static let sharedInstance = WebServer()
    
    
    // MARK: - Init
    private override init() {
        var urlPath: URL
        if let importAlbum = AlbumManager.sharedInstance.getAlbum(title: "Import") {
            urlPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(importAlbum.name!)
        } else {
            let album = AlbumManager.sharedInstance.addAlbum(title: "Import")
            urlPath = MediaLibrary.getDocumentsDirectory().appendingPathComponent(album.name!)
        }

        let fileExtensions = ["mov", "mp4", "gif", "jpg", "jpeg", "png"]
        webServer = GCDWebUploader(uploadDirectory: urlPath.path)
        webServer.allowedFileExtensions = fileExtensions
        currentDirectory = urlPath.absoluteString
    }

    // MARK: - Local variables
    private var webServer: GCDWebUploader
    private var currentDirectory: String
    weak var delegate: WebServerDelegate?
    
    // MARK: - Public method
    func setDelegate() {
        webServer.delegate = self
    }
    
    func startServer() {
        webServer.start()
    }
    
    func stopServer() {
        webServer.stop()
    }
    
    func setUploadDirectory(directory: String) {
        if directory != currentDirectory {
            webServer.stop()
            webServer = GCDWebUploader(uploadDirectory: directory)
            currentDirectory = directory
        }
    }
    
    func getAddress() -> String {
        if let serverUrl = webServer.serverURL {
            print("Server url : \(serverUrl)")
            if let bonjourServerURL = webServer.bonjourServerURL {
                print("Bonjour Server url : \(bonjourServerURL)")
                return bonjourServerURL.absoluteString
            } else {
                return serverUrl.absoluteString
            }
        }
        return "ADDRESS UNAVAILABLE!"
    }
    
    // MARK: - Private method
}

extension WebServer: GCDWebUploaderDelegate {
    public func webServerDidConnect(_ server: GCDWebServer) {
        delegate?.webServerDidConnect(webServer: self)
    }
    
    public func webServerDidDisconnect(_ server: GCDWebServer) {
        delegate?.webServerDidDisconnect(webServer: self)
    }
    
    public func webUploader(_ uploader: GCDWebUploader, didDownloadFileAtPath path: String) {
        delegate?.webServerDidDownloadFile(webServer: self, atPath: path)
    }
    
    public func webUploader(_ uploader: GCDWebUploader, didUploadFileAtPath path: String) {
        delegate?.webServerDidUploadFile(webServer: self, atPath: path)
    }
    
    public func webUploader(_ uploader: GCDWebUploader, didMoveItemFromPath fromPath: String, toPath: String) {
        
    }
    
    public func webUploader(_ uploader: GCDWebUploader, didDeleteItemAtPath path: String) {
        
    }
    
    public func webUploader(_ uploader: GCDWebUploader, didCreateDirectoryAtPath path: String) {
        
    }
}

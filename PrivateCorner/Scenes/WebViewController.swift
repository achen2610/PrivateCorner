//
//  WebViewController.swift
//  PrivateCorner
//
//  Created by a on 6/23/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit


class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    lazy var searchBars: UISearchBar = {
        let bars = UISearchBar(frame: CGRect(x: 0, y: 0, width: 288, height: 20))
        bars.delegate = self
        return bars
    }()
    
    // MARK: - Object lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleUI()
        loadData()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    // MARK: - Event handling
    func styleUI() {
        let leftNavBarButton = UIBarButtonItem(customView: searchBars)
        navigationItem.leftBarButtonItem = leftNavBarButton
    }
    
    func loadData() {
        let url = URL(string: "http://google.com")
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
        
        searchBars.text = "http://google.com"
    }
}

extension WebViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBars.showsCancelButton = true
        
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let string = searchBar.text {
            let url = URL(string: string)
            webView.loadRequest(URLRequest(url: url!))
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBars.resignFirstResponder()
        searchBars.showsCancelButton = false
    }
}

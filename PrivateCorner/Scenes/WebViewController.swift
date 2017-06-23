//
//  WebViewController.swift
//  PrivateCorner
//
//  Created by a on 6/23/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit


class WebViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    lazy var searchBars: UISearchBar = {
        let bars = UISearchBar(frame: CGRect(x: 0, y: 0, width: 288, height: 20))
        bars.delegate = self
        return bars
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftNavBarButton = UIBarButtonItem(customView: searchBars)
        navigationItem.leftBarButtonItem = leftNavBarButton
        
        let url = URL(string: "http://google.com")
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBars.showsCancelButton = true
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBars.resignFirstResponder()
        searchBars.showsCancelButton = false
    }
}

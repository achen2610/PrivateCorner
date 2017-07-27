//
//  WebViewController.swift
//  PrivateCorner
//
//  Created by a on 6/23/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit
import Photos

class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    lazy var containerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: kScreenHeight))
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    var albumCollectionView: UICollectionView!
    
    lazy var searchBars: UISearchBar = {
        let bars = UISearchBar(frame: CGRect(x: 0, y: 0, width: 288 * kScale, height: 44))
        bars.delegate = self
        return bars
    }()
    
    var viewModel: WebViewModel!
    var currentUrl: URL?
    var longPress: UILongPressGestureRecognizer?
    
    // MARK: - Object lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = WebViewModel()
        
        styleUI()
        loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextualMenuAction(notification:)), name: NSNotification.Name(rawValue: "TapAndHoldNotification"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    // MARK: - Event handling
    func styleUI() {
        let leftNavBarButton = UIBarButtonItem(customView: searchBars)
        navigationItem.leftBarButtonItem = leftNavBarButton
        
        searchBars.keyboardType = .webSearch
        searchBars.autocapitalizationType = .none
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(clickContainerView))
        gesture.delegate = self
        containerView.addGestureRecognizer(gesture)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = viewModel.cellSize()
        layout.sectionInset = UIEdgeInsets.zero
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        albumCollectionView = UICollectionView(frame: CGRect(x: 0, y: kScreenHeight - viewModel.cellSize().height - kTabBar, width: kScreenWidth, height: viewModel.cellSize().height), collectionViewLayout: layout)
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        albumCollectionView.backgroundColor = UIColor.white
        albumCollectionView.alwaysBounceHorizontal = true
        albumCollectionView.isUserInteractionEnabled = true
        let nibName = UINib(nibName: "WebAlbumCell", bundle:Bundle.main)
        albumCollectionView.register(nibName, forCellWithReuseIdentifier: viewModel.cellIdentifier())
        containerView.addSubview(albumCollectionView)
        view.addSubview(containerView)
    }
    
    func loadData() {
        let url = URL(string: "http://google.com")
        currentUrl = url
        let request = URLRequest(url: url!)
        webView.loadRequest(request)

        searchBars.text = "http://google.com"
    }
    
    func contextualMenuAction(notification: Notification) {
        var pt: CGPoint = CGPoint.zero
        let coord = notification.object as! [String: CGFloat]
        pt.x = coord["x"]!
        pt.y = coord["y"]!
        
        // convert point from window to view coordinate system
        pt = self.webView.convert(pt, from: nil)
        
        // convert point from view to HTML coordinate system
        let viewSize: CGSize = self.webView.frame.size
        let windowSize: CGSize = self.webView.windowSize()

        let f = windowSize.width / viewSize.width
        let fHeight = windowSize.height / viewSize.height
        pt.x = pt.x * f
        pt.y = pt.y * fHeight
        
        self.openContextualMenuAt(pt: pt)
    }
    
    func openContextualMenuAt(pt: CGPoint) {
        // Load the JavaScript code from the Resources and inject it into the web page
        let path = Bundle.main.path(forResource: "JSTools", ofType: ".js")
        var jsCode: String = ""
        do {
            jsCode = try String.init(contentsOfFile: path!, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        self.webView.stringByEvaluatingJavaScript(from: jsCode)

        // get the Tags at the touch location
        let tags = self.webView.stringByEvaluatingJavaScript(from: String.init(format: "GetHTMLElementsAtPoint(%f,%f);", pt.x, pt.y))
        let tagSRC = self.webView.stringByEvaluatingJavaScript(from: String.init(format: "GetLinkSRCAtPoint(%f,%f);", pt.x, pt.y))
        
        // create the UIAlertController and populate it with buttons related to the tags
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let downloadAction = UIAlertAction(title: "Download Photo", style: .default) { (alertAction) in
            if let src = tagSRC {
                let urlSRC = URL.init(string: src)!
                do {
                    let data = try Data.init(contentsOf: urlSRC)
                    let image = UIImage(data: data)
                    let filename = src.components(separatedBy: "/").last
                    
                    self.viewModel.getAlbumDownloads()
                    self.viewModel.uploadImageToDownloadAlbum(image: image!, filename: filename!)
                    
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
            }
        }
        let downloadToAction = UIAlertAction(title: "Download Photo To", style: .default) { (alertAction) in
            if let src = tagSRC {
                let urlSRC = URL.init(string: src)!
                do {
                    let data = try Data.init(contentsOf: urlSRC)
                    let image = UIImage(data: data)
                    let filename = src.components(separatedBy: "/").last
                    self.viewModel.setImageDownload(image: image!, filename: filename!)
                    
                    self.viewModel.getListAlbum()
                    self.albumCollectionView.reloadData()
                    
                    self.showCollectionView(show: true)

                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
            }
        }

        // If an image was touched, add image-related buttons
        if (tags?.range(of: ",IMG,")) != nil {
            alertController.addAction(downloadAction)
            alertController.addAction(downloadToAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func showCollectionView(show: Bool) {
        UIView.animate(withDuration: 0.5) { 
            if show {
                self.containerView.frame.origin = CGPoint(x: 0, y: 0)
            } else {
                self.containerView.frame.origin = CGPoint(x: 0, y: kScreenHeight)
            }
        }
    }
    
    func clickContainerView() {
        showCollectionView(show: false)
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
            var urlString = string
            if string.range(of: "http://") == nil || string.range(of: "https://") == nil {
                urlString = "http://" + string
            }
            
            let url = URL(string: urlString)
            currentUrl = url
            webView.loadRequest(URLRequest(url: url!))
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBars.resignFirstResponder()
        searchBars.showsCancelButton = false
    }
}

extension WebViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if navigationType == .linkClicked {
            searchBars.text = request.url?.absoluteString
            return true
        }
        
        if request.url?.absoluteString.range(of: currentUrl!.absoluteString) != nil {
            searchBars.text = request.url?.absoluteString
        }

        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.stringByEvaluatingJavaScript(from: "document.body.style.webkitTouchCallout='none';")
    }
}

extension WebViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: containerView))! {
            return false
        }
        return true
    }
}




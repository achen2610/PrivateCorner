//
//  WebViewController.swift
//  PrivateCorner
//
//  Created by a on 6/23/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit
import Photos
import CDAlertView

class WebViewController: BaseViewController {
    
    @IBOutlet weak var webView: UIWebView!
    var progressView: UIView!
    var progressRing: UICircularProgressRingView!
    var albumCollectionView: UICollectionView!
    var alert: CDAlertView!
    
    lazy var containerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: kScreenHeight))
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 14 * kScale)
        label.text = "Download photo to album"
        label.textAlignment = .center
        return label
    }()

    lazy var searchBars: UISearchBar = {
        let bars = UISearchBar(frame: CGRect(x: 0, y: 0, width: 288 * kScale, height: 44))
        bars.delegate = self
        return bars
    }()
    
    lazy var activity: UIActivityIndicatorView = {
        let act = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        act.frame = CGRect(x: 0, y: kNavigationView, width: kScreenWidth, height: kScreenHeight - kNavigationView - kTabBar)
        act.layer.backgroundColor = UIColor(white: 0.0, alpha: 0.2).cgColor
        return act
    }()
    
    lazy var footerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: kScreenHeight - kTabBar - 36 * kScale, width: kScreenWidth, height: 36 * kScale))
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        return view
    }()
    
    lazy var lineFooterView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 0.5))
        view.backgroundColor = UIColor(hex: "#DDDDDD")
        return view
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 8 * kScale, y: 3 * kScale, width: 30 * kScale, height: 30 * kScale))
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        return button
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 46 * kScale, y: 3 * kScale, width: 30 * kScale, height: 30 * kScale))
        button.setImage(UIImage(named: "next"), for: .normal)
        button.addTarget(self, action: #selector(clickNextButton), for: .touchUpInside)
        return button
    }()
    
    var viewModel: WebViewModel!
    var currentUrl: URL?
    var downloadUrl: URL?
    var longPress: UILongPressGestureRecognizer?
    var isShow = false
    var isUploading: Bool = false
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadVideo), name: NSNotification.Name(rawValue: "DownloadVideoNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemBecameCurrent(notification:)), name: NSNotification.Name("AVPlayerItemBecameCurrentNotification"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        showCollectionView(show: false)
        showFooterView(show: true)
    }
    
    // MARK: - Event handling
    func styleUI() {
        webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 36 * kScale, 0)
        
        let leftNavBarButton = UIBarButtonItem(customView: searchBars)
        navigationItem.leftBarButtonItem = leftNavBarButton
        
        searchBars.keyboardType = .webSearch
        searchBars.autocapitalizationType = .none
        
        view.addSubview(activity)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(clickContainerView))
        gesture.delegate = self
        containerView.addGestureRecognizer(gesture)
        view.addSubview(containerView)
        
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
        
        titleLabel.frame = CGRect(x: 0, y: albumCollectionView.frame.minY - 24 * kScale, width: kScreenWidth, height: 24 * kScale)
        containerView.addSubview(titleLabel)
        
        footerView.addSubview(lineFooterView)
        footerView.addSubview(backButton)
        footerView.addSubview(nextButton)
        view.addSubview(footerView)
        
        progressView = UIView()
        progressView.backgroundColor = UIColor.clear
        progressView.heightAnchor.constraint(equalToConstant: 153.0).isActive = true
        
        progressRing = UICircularProgressRingView(frame: CGRect(x: 35, y: 0, width: 153, height: 153))
        // Change any of the properties you'd like
        let blue = UIColor(hexString: "#3498db")
        progressRing.outerRingColor = blue
        progressRing.outerRingWidth = 8.0
        progressRing.innerRingColor = blue.lighter()
        progressRing.innerRingSpacing = 0
        progressRing.fontColor = blue.darkened()
        progressView.addSubview(progressRing)
    }
    
    func loadData() {
        activity.startAnimating()
        
        let url = URL(string: "http://google.com")
        currentUrl = url
        let request = URLRequest(url: url!)
        webView.loadRequest(request)

        searchBars.text = "http://google.com"
    }
    
    @objc func contextualMenuAction(notification: Notification) {
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
                    let subtype = MediaLibrary.getSubTypeOfFile(filename: filename!)
                    
                    self.viewModel.getAlbumDownloads()
                    if subtype == "gif" {
                        self.viewModel.uploadGifImageToAlbum(data: data, filename: filename, album: nil)
                    } else {
                        self.viewModel.uploadImageToDownloadAlbum(image: image!, filename: filename!)
                    }
                    
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
                    let filename = src.components(separatedBy: "/").last
                    self.viewModel.setImageDownload(data: data, filename: filename!)
                    
                    self.viewModel.getListAlbum()
                    self.albumCollectionView.reloadData()
                    
                    self.showCollectionView(show: true)
                    self.showFooterView(show: false)

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
        if show && isShow {
            return
        } else if !show && !isShow {
            return
        }
        
        isShow = !isShow
        
        UIView.animate(withDuration: 0.5) { 
            if show {
                self.containerView.frame.origin = CGPoint(x: 0, y: 0)
            } else {
                self.containerView.frame.origin = CGPoint(x: 0, y: kScreenHeight)
            }
        }
    }
    
    func showFooterView(show: Bool) {
        UIView.animate(withDuration: 0.5) { 
            if show {
                self.footerView.frame.origin = CGPoint(x: 0, y: kScreenHeight - kTabBar - 36 * kScale)
            } else {
                self.footerView.frame.origin = CGPoint(x: 0, y: kScreenHeight)
            }
        }
    }
    
    @objc func playerItemBecameCurrent(notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem,
            let asset = playerItem.asset as? AVURLAsset else {return}
        let url = asset.url
        print("url \(url)")
        
        downloadUrl = url
    }
    
    @objc func handleDownloadVideo() {
        if let url = downloadUrl {
            isUploading = true
            progressRing.alpha = 1.0
            alert = CDAlertView(title: nil, message: "Downloading!", type: .warning)
            alert.customView = progressView
            alert.isUserInteractionEnabled = false
            alert.show()
            
            let req = NSMutableURLRequest(url:url)
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
            
            let task : URLSessionDownloadTask = session.downloadTask(with: req as URLRequest)
            task.resume()
        }
    }
    
    // MARK: - Event selector
    @objc func clickContainerView() {
        showCollectionView(show: false)
        showFooterView(show: true)
    }
    
    @objc func clickBackButton() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc func clickNextButton() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
}

extension WebViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBars.showsCancelButton = true
        showCollectionView(show: false)
        showFooterView(show: true)
        
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBars.resignFirstResponder()
        searchBars.showsCancelButton = false
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
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activity.stopAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.stringByEvaluatingJavaScript(from: "document.body.style.webkitTouchCallout='none';")
        let currentURL = webView.stringByEvaluatingJavaScript(from: "window.location.href")
        searchBars.text = currentURL
        
        activity.stopAnimating()
        showFooterView(show: true)
    }
}

extension WebViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == containerView {
            return true
        }
        return false
    }
}

extension WebViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if isUploading {
            isUploading = false
            alert.hide(isPopupAnimated: false)
            alert = CDAlertView(title: nil, message: "Download error! Please try again!", type: .success)
            alert.isUserInteractionEnabled = true
            alert.show()
            progressRing.setProgress(value: 0, animationDuration: 0)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.downloadButton.isUserInteractionEnabled = true
            
            delay(1.2, execute: {
                self.alert.hide(isPopupAnimated: true)
            })
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let value = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite) * 100
        self.progressRing.setProgress(value: value, animationDuration: 0.3)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if isUploading {
            isUploading = false
            alert.hide(isPopupAnimated: false)
            alert = CDAlertView(title: nil, message: "Download success!", type: .success)
            alert.isUserInteractionEnabled = true
            alert.show()
            progressRing.setProgress(value: 0, animationDuration: 0)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.downloadButton.isUserInteractionEnabled = true
            
            delay(1.2, execute: {
                self.alert.hide(isPopupAnimated: true)
            })
            
            viewModel.getAlbumDownloads()
            viewModel.uploadVideoToAlbum(url: location, downloadUrl: downloadUrl!)
        }
    }
}




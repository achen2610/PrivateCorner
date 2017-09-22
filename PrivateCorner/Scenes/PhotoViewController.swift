//
//  PhotoViewController.swift
//  PrivateCorner
//
//  Created by a on 5/23/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit
import MessageUI
import CDAlertView

class PhotoViewController: UIViewController, PhotoViewViewModelDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var viewModel: PhotoViewViewModel!
    var selectedIndex: IndexPath?
    var currentIndex: IndexPath!
    var panGR = UIPanGestureRecognizer()
    var isHiddenNav: Bool = false
    var alert: CDAlertView!
    
    struct cellIdentifiers {
        static let photoCell = "PhotoCell"
        static let videoCell = "VideoCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        styleUI()
        configureCollectionViewOnLoad()
        
        if let selectedIndex = selectedIndex {
            currentIndex = selectedIndex
            let title = viewModel.getUploadDate(index: selectedIndex.row)
            setupTitleView(topText: title.first ?? "", bottomText: title.last ?? "")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isHeroEnabled = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.tabBarController?.tabBar.alpha = 0.0
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppUtility.lockOrientation(.allButUpsideDown)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tabBarController?.tabBar.alpha = 1.0
        AppUtility.lockOrientation(.portrait)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        if collectionView.visibleCells.count > 0 {
            if let cell = collectionView?.visibleCells[0] as? PhotoCell {
                
            }
            
            if let cell = collectionView?.visibleCells[0] as? VideoCell {
                cell.containerView.frame = cell.bounds
                cell.playButton.frame = cell.bounds
                cell.playerLayer.frame = cell.containerView.bounds
            }
        }
        
        
        
        if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            //here you can do the logic for the cell size if phone is in landscape
            
        } else {
            //logic if not landscape
        }
        
        flowLayout.invalidateLayout()
    }
    
    // MARK: - Event handling
    func styleUI() {
        automaticallyAdjustsScrollViewInsets = false
        preferredContentSize = CGSize(width: view.bounds.width, height: view.bounds.width)
        toolBar.frame.origin.y += toolBar.frame.size.height
        toolBar.barTintColor = navigationController?.navigationBar.barTintColor
    }
    
    func rotateUI(isLandscape: Bool) {
        if isLandscape {
            
        } else {
            
        }
    }
    
    func configureCollectionViewOnLoad() {
        collectionView.register(UINib(nibName: "PhotoCell", bundle:Bundle.main), forCellWithReuseIdentifier: cellIdentifiers.photoCell)
        collectionView.register(UINib(nibName: "VideoCell", bundle:Bundle.main), forCellWithReuseIdentifier: cellIdentifiers.videoCell)
        
        view.layoutIfNeeded()
        collectionView!.reloadData()
        if let selectedIndex = selectedIndex {
            collectionView!.scrollToItem(at: selectedIndex, at: .centeredHorizontally, animated: false)
            let type = viewModel.getTypeItem(index: selectedIndex.row)
            if type == "image" {
                actionButton.isEnabled = false
            } else {
                actionButton.isEnabled = true
            }
        }
        
        panGR.addTarget(self, action: #selector(pan))
        panGR.delegate = self
        collectionView?.addGestureRecognizer(panGR)
    }
    
    func setupTitleView(topText: String, bottomText: String) {
        let titleParameters = [NSForegroundColorAttributeName : UIColor.white,
                               NSFontAttributeName : UIFont.systemFont(ofSize: 16)]
        let subtitleParameters = [NSForegroundColorAttributeName : UIColor.white,
                                  NSFontAttributeName : UIFont.systemFont(ofSize: 12)]
        
        let title:NSMutableAttributedString = NSMutableAttributedString(string: topText, attributes: titleParameters)
        let subtitle:NSAttributedString = NSAttributedString(string: bottomText, attributes: subtitleParameters)
        
        title.append(NSAttributedString(string: "\n"))
        title.append(subtitle)
        
        let size = title.size()
        
        let width = size.width
        guard let height = navigationController?.navigationBar.frame.size.height else {return}
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        titleLabel.attributedText = title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        navigationItem.titleView = titleLabel
    }
    
    func alertExport() {
        alert = CDAlertView(title: nil, message: "Do you want to export images to Photo Library?", type: .warning)
        let alertAction = CDAlertViewAction(title: "Export", font: nil, textColor: nil, backgroundColor: nil) { (action) in
            self.viewModel.exportFile(index: self.currentIndex.row, type: .PhotoLibrary)
        }
        alert.add(action: alertAction)
        let cancelAction = CDAlertViewAction(title: "Cancel")
        alert.add(action: cancelAction)
        alert.show()
    }
    
    func emailExport() {
        if MFMailComposeViewController.canSendMail() {
            viewModel.exportFile(index: currentIndex.row, type: .Email)
        }
    }
    
    func copyImages() {
        viewModel.exportFile(index: currentIndex.row, type: .Copy)
    }
    
    // MARK: - Selector Event
    func pan() {
        let translation = panGR.translation(in: nil)
        let progress = translation.y / 2 / collectionView!.bounds.height
        switch panGR.state {
        case .began:
            if let cell = collectionView?.visibleCells[0] as? VideoCell {
                cell.setHiddenForPlayButton(isHidden: true)
            }
            
            tabBarController?.tabBar.alpha = 1.0
            if isHiddenNav {
                navigationController?.navigationBar.alpha = 1.0
                isHiddenNav = !isHiddenNav
            }

            hero_dismissViewController()
        case .changed:
            Hero.shared.update(progress: Double(progress))
            if let cell = collectionView?.visibleCells[0]  as? PhotoCell {
                let currentPos = CGPoint(x: translation.x + view.center.x, y: translation.y + view.center.y)
                Hero.shared.apply(modifiers: [.position(currentPos)], to: cell.imageView)
            }
            if let cell = collectionView?.visibleCells[0]  as? VideoCell {
                let currentPos = CGPoint(x: translation.x + view.center.x, y: translation.y + view.center.y)
                Hero.shared.apply(modifiers: [.position(currentPos)], to: cell.containerView)
            }
        default:
            if progress + panGR.velocity(in: nil).y / collectionView!.bounds.height > 0.3 {
                Hero.shared.end()
            } else {
                Hero.shared.cancel()
                if let cell = collectionView?.visibleCells[0] as? VideoCell {
                    cell.setHiddenForPlayButton(isHidden: false)
                }
            }
        }
    }

    @IBAction func clickExportButton(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: "Export to", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Photo Library", style: .default) { (alertAction) in
            self.alertExport()
        }
        let emailAction = UIAlertAction(title: "Email", style: .default) { (alertAction) in
            self.emailExport()
        }
        let copyAction = UIAlertAction(title: "Copy", style: .default) { (alertAction) in
            self.copyImages()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(emailAction)
        alertController.addAction(copyAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func clickActionButton(_ sender: Any) {
        if let cell = collectionView?.visibleCells[0] as? VideoCell {
            if cell.player.isPlaying {
                print("is playing")
                cell.pauseVideo()
                actionButton.image = UIImage(named: "play.png")
            } else {
                cell.playVideo()
            }
        }
    }

    @IBAction func clickDeleteButton(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: "Do you want to delete this image?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (deleteAction) in
            if let indexPath = self.collectionView.indexPathsForVisibleItems.first {
                self.viewModel.deleteItem(index: indexPath.row, collectionView: self.collectionView)
            }
        }
        deleteAction.setValue(UIColor(hexString: "#F71700"), forKey: "titleTextColor")
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - PhotoViewViewModel Delegate
    func exportSuccess() {
        DispatchQueue.main.async {
            self.alert = CDAlertView(title: nil, message: "Export image to Photo Library success!", type: .success)
            delay(0.3, execute: {
                self.alert.show()
            })
            delay(1.0, execute: {
                self.alert.hide(isPopupAnimated: true)
            })
        }
    }
    
    func sendEmail(emailVC: MFMailComposeViewController) {
        emailVC.mailComposeDelegate = self
        present(emailVC, animated: true, completion: nil)
    }
    
    func copyImagesSuccess() {
        alert = CDAlertView(title: nil, message: "Copy image success!", type: .success)
        alert.show()
        
        delay(0.7, execute: {
            self.alert.hide(isPopupAnimated: true)
        })
    }
    
    func deleteSuccess() {
        alert = CDAlertView(title: nil, message: "Delete image success!", type: .success)
        alert.show()
        
        delay(0.7, execute: { 
            self.alert.hide(isPopupAnimated: true)
        })
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Key.String.notiUpdateGallery), object: nil)
    }
}

extension PhotoViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let cell = collectionView?.visibleCells[0] as? PhotoCell, cell.scrollView.zoomScale == 1 {
            let v = panGR.velocity(in: nil)
            return v.y > abs(v.x)
        }
        if let _ = collectionView?.visibleCells[0] as? VideoCell {
            let v = panGR.velocity(in: nil)
            return v.y > abs(v.x)
        }
        return false
    }
}

extension PhotoViewController: HeroViewControllerDelegate {
    
    func heroDidEndTransition() {
        viewModel.isEndTransition = true
        if let cell = collectionView?.visibleCells[0] as? VideoCell {
            cell.playButton.isHidden = false
        }
        
        toolBar.isHidden = false
        UIView.animate(withDuration: 0.1) {
            self.toolBar.frame.origin.y -= self.toolBar.frame.size.height
        }
    }
}

extension PhotoViewController: VideoCellDelegate {
    func tapOverVideoView() {
        if isHiddenNav {
            UIView.animate(withDuration: 0.3, animations: { 
                self.navigationController?.navigationBar.alpha = 1.0
                self.toolBar.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.navigationController?.navigationBar.alpha = 0.0
                self.toolBar.alpha = 0.0
            })
        }
        isHiddenNav = !isHiddenNav
    }
    
    func tapPlayVideo() {
        UIView.animate(withDuration: 0.3, animations: {
            self.navigationController?.navigationBar.alpha = 0.0
            self.toolBar.alpha = 0.0
            self.actionButton.image = UIImage(named: "pause.png")
        })
        isHiddenNav = !isHiddenNav
    }
    
    func videoPlayFinished() {
        UIView.animate(withDuration: 0.3, animations: {
            self.navigationController?.navigationBar.alpha = 1.0
            self.toolBar.alpha = 1.0
            self.actionButton.image = UIImage(named: "play.png")
        })
        isHiddenNav = !isHiddenNav
    }
}

extension PhotoViewController: PhotoCellDelegate {
    func tapPhotoView() {
        if isHiddenNav {
            UIView.animate(withDuration: 0.3, animations: {
                self.navigationController?.navigationBar.alpha = 1.0
                self.toolBar.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.navigationController?.navigationBar.alpha = 0.0
                self.toolBar.alpha = 0.0
            })
        }
        isHiddenNav = !isHiddenNav
    }
}

extension PhotoViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent:
            alert = CDAlertView(title: nil, message: "Send email success!", type: .success)
            alert.show()
            
            delay(0.7, execute: { 
                self.alert.hide(isPopupAnimated: true)
            })
            break
        case .cancelled, .saved:
            controller.dismiss(animated: true, completion: nil)
            break
        case .failed:
            alert = CDAlertView(title: nil, message: "Send email failed!", type: .success)
            alert.show()
            
            delay(0.7, execute: {
                self.alert.hide(isPopupAnimated: true)
            })
            break
        }
    }
}

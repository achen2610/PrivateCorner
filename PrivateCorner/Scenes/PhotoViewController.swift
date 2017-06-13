//
//  PhotoViewController.swift
//  PrivateCorner
//
//  Created by a on 5/23/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    var viewModel: PhotoViewViewModel!
    var selectedIndex: IndexPath?
    var panGR = UIPanGestureRecognizer()
    var isHiddenNav: Bool = false
    
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
        
        styleUI()
        configureCollectionViewOnLoad()
        
        if let selectedIndex = selectedIndex {
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tabBarController?.tabBar.alpha = 1.0
    }
    
    // MARK: Event handling
    func styleUI() {
        automaticallyAdjustsScrollViewInsets = false
        preferredContentSize = CGSize(width: view.bounds.width, height: view.bounds.width)
        toolBar.frame.origin.y += toolBar.frame.size.height
        toolBar.barTintColor = navigationController?.navigationBar.barTintColor
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
        let titleParameters = [NSForegroundColorAttributeName : UIColor.black,
                               NSFontAttributeName : UIFont.systemFont(ofSize: 16)]
        let subtitleParameters = [NSForegroundColorAttributeName : UIColor.black,
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
    
    // MARK: Selector Event
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
        if let indexPath = collectionView.indexPathsForVisibleItems.first {
            viewModel.deleteItem(index: indexPath.row, collectionView: collectionView)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Key.String.notiUpdateCollectionView), object: nil)
        }
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

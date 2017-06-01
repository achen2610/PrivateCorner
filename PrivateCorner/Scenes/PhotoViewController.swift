//
//  PhotoViewController.swift
//  PrivateCorner
//
//  Created by a on 5/23/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
    var viewModel: PhotoViewViewModel!
    var selectedIndex: IndexPath?
    var panGR = UIPanGestureRecognizer()
    var isHiddenNav: Bool = false
    
    
    struct cellIdentifiers {
        static let photoCell = "PhotoCell"
        static let videoCell = "VideoCell"
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleUI()
        configureCollectionViewOnLoad()
    }
    
    
    // MARK: Event handling
    func styleUI() {
        automaticallyAdjustsScrollViewInsets = false
        preferredContentSize = CGSize(width: view.bounds.width, height: view.bounds.width)
    }
    
    func configureCollectionViewOnLoad() {
        collectionView.register(UINib(nibName: "PhotoCell", bundle:Bundle.main), forCellWithReuseIdentifier: cellIdentifiers.photoCell)
        collectionView.register(UINib(nibName: "VideoCell", bundle:Bundle.main), forCellWithReuseIdentifier: cellIdentifiers.videoCell)
        
        view.layoutIfNeeded()
        collectionView!.reloadData()
        if let selectedIndex = selectedIndex {
            collectionView!.scrollToItem(at: selectedIndex, at: .centeredHorizontally, animated: false)
        }
        
        panGR.addTarget(self, action: #selector(pan))
        panGR.delegate = self
        collectionView?.addGestureRecognizer(panGR)
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
            
            if isHiddenNav {
                self.navigationController?.navigationBar.alpha = 1.0
                self.tabBarController?.tabBar.alpha = 1.0
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
    
    public func heroDidEndTransition() {
        viewModel.isEndTransition = true
        if let cell = collectionView?.visibleCells[0] as? VideoCell {
            cell.playButton.isHidden = false
        }
    }
}

extension PhotoViewController: VideoCellDelegate {
    func tapOverVideoView() {
        if isHiddenNav {
            UIView.animate(withDuration: 0.3, animations: { 
                self.navigationController?.navigationBar.alpha = 1.0
                self.tabBarController?.tabBar.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.navigationController?.navigationBar.alpha = 0.0
                self.tabBarController?.tabBar.alpha = 0.0
            })
        }
        isHiddenNav = !isHiddenNav
    }
}

extension PhotoViewController: PhotoCellDelegate {
    func tapPhotoView() {
        if isHiddenNav {
            UIView.animate(withDuration: 0.3, animations: {
                self.navigationController?.navigationBar.alpha = 1.0
                self.tabBarController?.tabBar.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.navigationController?.navigationBar.alpha = 0.0
                self.tabBarController?.tabBar.alpha = 0.0
            })
        }
        isHiddenNav = !isHiddenNav
    }
}

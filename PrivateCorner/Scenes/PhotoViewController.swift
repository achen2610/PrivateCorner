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
    
    struct cellIdentifiers {
        static let photoCell = "PhotoCell"
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        for v in (collectionView!.visibleCells as? [PhotoCell])! {
            v.topInset = topLayoutGuide.length
            v.bottomInset = bottomLayoutGuide.length
        }
    }
    
    // MARK: Event handling
    func styleUI() {
        automaticallyAdjustsScrollViewInsets = false
        preferredContentSize = CGSize(width: view.bounds.width, height: view.bounds.width)
    }
    
    func configureCollectionViewOnLoad() {
        let nibName = UINib(nibName: "PhotoCell", bundle:Bundle.main)
        collectionView.register(nibName, forCellWithReuseIdentifier: cellIdentifiers.photoCell)
        
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
            hero_dismissViewController()
        case .changed:
            Hero.shared.update(progress: Double(progress))
            if let cell = collectionView?.visibleCells[0]  as? PhotoCell {
                let currentPos = CGPoint(x: translation.x + view.center.x, y: translation.y + view.center.y)
                Hero.shared.apply(modifiers: [.position(currentPos)], to: cell.imageView)
            }
        default:
            if progress + panGR.velocity(in: nil).y / collectionView!.bounds.height > 0.3 {
                Hero.shared.end()
            } else {
                Hero.shared.cancel()
            }
        }
    }
}

extension PhotoViewController:UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let cell = collectionView?.visibleCells[0] as? PhotoCell,
            cell.scrollView.zoomScale == 1 {
            let v = panGR.velocity(in: nil)
            return v.y > abs(v.x)
        }
        return false
    }
}

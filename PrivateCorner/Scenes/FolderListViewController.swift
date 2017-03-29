//
//  FolderListViewController.swift
//  PrivateCorner
//
//  Created by a on 3/15/17.
//  Copyright (c) 2017 MrAChen. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit

protocol FolderListViewControllerInput {
    
}

protocol FolderListViewControllerOutput {
    
}

class FolderListViewController: UIViewController, FolderListViewControllerInput {
    
    var output: FolderListViewControllerOutput!
    var router: FolderListRouter!
    
    @IBOutlet weak var folderCollectionView: UICollectionView!
    
    // MARK: Object lifecycle
    
    struct cellIdentifiers {
        static let folderCell = "folderCell"
    }
    
    struct cellLayout {
        static let itemsPerRow: CGFloat = 2
        static let sectionInsets: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        FolderListConfigurator.sharedInstance.configure(viewController: self)
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionViewOnLoad()
    }
    
    // MARK: Event handling
    
    func configureCollectionViewOnLoad() {
        let nibName = UINib(nibName: "FolderListCell", bundle:Bundle.main)
        folderCollectionView.register(nibName, forCellWithReuseIdentifier: cellIdentifiers.folderCell)
    }
    
    func selectedPhotoAtIndex(index: Int) {
        
        
        router.navigateToPhotoScreen()
    }
    
    // MARK: Display logic
    
}

//This should be on configurator but for some reason storyboard doesn't detect ViewController's name if placed there
extension FolderListViewController: FolderListPresenterOutput {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router.passDataToNextScene(for: segue)
    }
}

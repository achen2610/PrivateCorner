//
//  AddFileViewController.swift
//  PrivateCorner
//
//  Created by a on 6/13/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class MoveFileViewController: BaseViewController, MoveFileViewModelDelegate {

    var viewModel: MoveFileViewModel!

    @IBOutlet weak var albumsCollectionView: UICollectionView!
    
    // MARK: Object lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Key.Screen.moveFile
        configureCollectionViewOnLoad()
        viewModel.delegate = self
        viewModel.getAlbumFromCoreData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.getAlbumFromCoreData()
    }
    
    // MARK: Event handling
    
    func configureCollectionViewOnLoad() {
        let nibName = UINib(nibName: "MoveFileCell", bundle:Bundle.main)
        albumsCollectionView.register(nibName, forCellWithReuseIdentifier: viewModel.cellIdentifier())
        albumsCollectionView.alwaysBounceVertical = true
    }
    
    @IBAction func clickCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: MoveFileViewModelDelegate
    func moveFileToAlbum(onSuccess: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Key.SString.notiUpdateGalleryWhenMoveFile), object: nil)
        
        dismiss(animated: true, completion: nil)
    }
}

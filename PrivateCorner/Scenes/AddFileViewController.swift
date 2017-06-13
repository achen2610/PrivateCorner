//
//  AddFileViewController.swift
//  PrivateCorner
//
//  Created by a on 6/13/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

class AddFileViewController: UIViewController, AddFileViewModelDelegate {

    var viewModel: AddFileViewModel!

    @IBOutlet weak var albumsCollectionView: UICollectionView!
    
    // MARK: Object lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Photos to Album"
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
        let nibName = UINib(nibName: "AddFileCell", bundle:Bundle.main)
        albumsCollectionView.register(nibName, forCellWithReuseIdentifier: viewModel.cellIdentifier())
        albumsCollectionView.alwaysBounceVertical = true
    }
    
    @IBAction func clickCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: AlbumsViewModelDelegate
    func moveFileToAlbum(onSuccess: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Key.String.notiUpdateCollectionView), object: nil)
        
        dismiss(animated: true, completion: nil)
    }
}

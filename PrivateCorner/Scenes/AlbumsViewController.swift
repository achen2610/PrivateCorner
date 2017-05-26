//
//  AlbumsViewController.swift
//  PrivateCorner
//
//  Created by a on 3/15/17.
//  Copyright (c) 2017 MrAChen. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit

class AlbumsViewController: UIViewController, AlbumsViewModelDelegate {

    var viewModel: AlbumsViewModel!
    var isEditMode: Bool = false
    
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    
    // MARK: Object lifecycle
    
    struct cellIdentifiers {
        static let albumsCell = "albumsCell"
    }
    
    struct cellLayout {
        static let itemsPerRow: CGFloat = 2
        static let sectionInsets: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Album"
        configureCollectionViewOnLoad()
        viewModel = AlbumsViewModel(delegate: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.getAlbumFromCoreData()
    }
    
    // MARK: Event handling
    
    func configureCollectionViewOnLoad() {
        let nibName = UINib(nibName: "AlbumsCell", bundle:Bundle.main)
        albumsCollectionView.register(nibName, forCellWithReuseIdentifier: cellIdentifiers.albumsCell)
    }

    
    @IBAction func addAlbumButtonItemTapped(_ sender: Any) {
        let alert = UIAlertController.init(title: "New Album", message: "Enter a name for this album", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .alphabet
            textField.placeholder = "Title"
        }
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let saveAction = UIAlertAction.init(title: "Save", style: .default) { (action) in
            let textField = alert.textFields?.first

            self.albumsCollectionView.performBatchUpdates({
                self.viewModel.saveAlbumToCoreData(title: (textField?.text)!)
                self.albumsCollectionView.insertItems(at: [IndexPath.init(row: 0, section: 0)])
            }, completion: nil)
        }
        alert.addAction(saveAction)

        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func editAlbumButtonItemTapped(_ sender: Any) {
        if !isEditMode {
            isEditMode = true
            albumsCollectionView.reloadData()
            
            let barButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editAlbumButtonItemTapped(_:)))
            self.navigationItem.rightBarButtonItem = barButton
        } else {
            isEditMode = false
            albumsCollectionView.reloadData()
            
            let barButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editAlbumButtonItemTapped(_:)))
            self.navigationItem.rightBarButtonItem = barButton
        }
    }
    
    func clickDeleteAlbum(button: UIButton) {
        let index = button.tag

        albumsCollectionView.performBatchUpdates({
            self.viewModel.deleteAlbumFromList(index: index)
            self.albumsCollectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
            self.albumsCollectionView.reloadData()
        }, completion: nil)
        
    }
    
    // MARK: AlbumsViewModelDelegate
    func navigationToAlbumDetail(viewModel: GalleryPhotoViewModel){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller  = mainStoryboard.instantiateViewController(withIdentifier: "GalleryPhoto") as! GalleryPhotoViewController
        viewModel.delegate = controller
        controller.viewModel = viewModel
        
        // Push to gallery photo
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func reloadAlbum() {
        albumsCollectionView.reloadData()
    }
    
    // MARK: Keyboard Function
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let adjustmentHeight = keyboardFrame.height
        var contentInset:UIEdgeInsets = albumsCollectionView.contentInset
        contentInset.bottom = adjustmentHeight

        albumsCollectionView.contentInset = contentInset
        albumsCollectionView.scrollIndicatorInsets = contentInset
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var contentInset:UIEdgeInsets = albumsCollectionView.contentInset
        contentInset.bottom = 49.0

        albumsCollectionView.contentInset = contentInset
        albumsCollectionView.scrollIndicatorInsets = contentInset
    }
}

extension AlbumsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let index = textField.tag
        let indexPath = IndexPath(row: index, section: 0)
        albumsCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let index = textField.tag
        let title = textField.text!
        viewModel.editAlbum(title: title, atIndex: index)
    }

}

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
import CDAlertView

class AlbumsViewController: BaseViewController, AlbumsViewModelDelegate {

    var viewModel: AlbumsViewModel!
    var isEditMode: Bool = false
    
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    @IBOutlet weak var noAlbumView: UIView!
    
    // MARK: Object lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Key.Screen.album
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        viewModel = AlbumsViewModel(delegate: self)
        viewModel.getAlbumFromCoreData()
        configureCollectionViewOnLoad()
        
        // StyleUI
        noAlbumView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.getAlbumFromCoreData()
    }
    
    // MARK: - Event handling
    
    func configureCollectionViewOnLoad() {
        let nibName = UINib(nibName: "AlbumsCell", bundle:Bundle.main)
        albumsCollectionView.register(nibName, forCellWithReuseIdentifier: viewModel.cellIdentifier())
        albumsCollectionView.alwaysBounceVertical = true
    }
    
    func styleNoAlbumView() {
        if viewModel.numberItemInSection(section: 0) > 0 {
            noAlbumView.isHidden = true
        } else {
            noAlbumView.isHidden = false
        }
    }

    // MARK: - Event selectors
    
    @IBAction func addAlbumButtonItemTapped(_ sender: Any) {
        let alert = UIAlertController.init(title: "New Album", message: "Enter a name for this album", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .alphabet
            textField.placeholder = "Name"
        }
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let saveAction = UIAlertAction.init(title: "Save", style: .default) { (action) in
            let textField = alert.textFields?.first
            if let text = textField?.text, text != "" {
                self.albumsCollectionView.performBatchUpdates({
                    self.viewModel.saveAlbumToCoreData(title: (textField?.text)!)
                    self.albumsCollectionView.insertItems(at: [IndexPath.init(row: 0, section: 0)])
                    self.styleNoAlbumView()
                }) { (finished) in
                    
                }
            }
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
    
    @objc func clickDeleteAlbum(button: UIButton) {
        let index = button.tag

        albumsCollectionView.performBatchUpdates({
            self.viewModel.deleteAlbumFromList(index: index)
            self.albumsCollectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        }) { (finished) in
            if finished {
                self.albumsCollectionView.reloadData()
                self.styleNoAlbumView()
            }
        }
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
        styleNoAlbumView()
    }
    
    // MARK: Keyboard Function
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let adjustmentHeight = keyboardFrame.height
        var contentInset:UIEdgeInsets = albumsCollectionView.contentInset
        contentInset.bottom = adjustmentHeight

        albumsCollectionView.contentInset = contentInset
        albumsCollectionView.scrollIndicatorInsets = contentInset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        var contentInset:UIEdgeInsets = albumsCollectionView.contentInset
        contentInset.bottom = 49.0

        albumsCollectionView.contentInset = contentInset
        albumsCollectionView.scrollIndicatorInsets = contentInset
    }
}

extension AlbumsViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let index = textField.tag
        let indexPath = IndexPath(row: index, section: 0)
        albumsCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let index = textField.tag
        let title = textField.text!
        viewModel.editAlbum(title: title, atIndex: index)
    }

}

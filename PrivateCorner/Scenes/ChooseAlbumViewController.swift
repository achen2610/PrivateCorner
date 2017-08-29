//
//  ChooseAlbumViewController.swift
//  PrivateCorner
//
//  Created by a on 8/29/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit

class ChooseAlbumViewController: UIViewController, ChooseAlbumViewModelDelegate {
    
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    var viewModel: ChooseAlbumViewModel!
    var gallery: GalleryController!
    var isRequestPermission: Bool = false
    var isPhotoLibrary: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Key.Screen.chooseAlbum
        
        viewModel = ChooseAlbumViewModel()
        viewModel.delegate = self
        viewModel.getAlbumFromCoreData()
        configureCollectionViewOnLoad()
    }

    // MARK: Event handling
    
    func configureCollectionViewOnLoad() {
        let nibName = UINib(nibName: "ChooseAlbumCell", bundle:Bundle.main)
        albumsCollectionView.register(nibName, forCellWithReuseIdentifier: viewModel.cellIdentifier())
        albumsCollectionView.alwaysBounceVertical = true
    }

    @IBAction func clickedCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: ChooseAlbumViewModelDelegate
    func chooseAlbumSuccess(onSuccess: Bool) {
        if isPhotoLibrary {
            if SPRequestPermission.isAllowPermissions([.photoLibrary]) {
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                    Config.showsPhotoLibraryTab = true
                    Config.showsCameraTab = false
                    Config.showsVideoTab = true
                    self.gallery = GalleryController()
                    self.gallery.delegate = self
                    self.navigationController?.pushViewController(self.gallery, animated: true)
                }
            } else {
                self.isRequestPermission = true
                SPRequestPermission.dialog.interactive.present(on: self, with: [.photoLibrary], dataSource: CustomDataSource(), delegate: self)
            }
        } else {
            if SPRequestPermission.isAllowPermissions([.camera]) {
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                    Config.showsPhotoLibraryTab = false
                    Config.showsCameraTab = true
                    Config.showsVideoTab = false
                    self.gallery = GalleryController()
                    self.gallery.delegate = self
                    self.navigationController?.pushViewController(self.gallery, animated: true)
                }
            } else {
                self.isRequestPermission = true
                SPRequestPermission.dialog.interactive.present(on: self, with: [.camera], dataSource: CustomDataSource(), delegate: self)
            }
        }
    }
}

extension ChooseAlbumViewController: SPRequestPermissionEventsDelegate {
    func didHide() {
        isRequestPermission = false
        var permission: [SPRequestPermissionType]
        if isPhotoLibrary {
            permission = [.photoLibrary]
        } else {
            permission = [.camera]
        }
        
        if SPRequestPermission.isAllowPermissions(permission) {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                self.gallery = GalleryController()
                self.gallery.delegate = self
                self.navigationController?.pushViewController(self.gallery, animated: true)
            }
        }
    }
    
    func didAllowPermission(permission: SPRequestPermissionType) {
        
    }
    
    func didDeniedPermission(permission: SPRequestPermissionType) {
        
    }
    
    func didSelectedPermission(permission: SPRequestPermissionType) {
        
    }
}

extension ChooseAlbumViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [UIImage]) {
        DispatchQueue.main.async {
            controller.dismiss(animated: true, completion: nil)
            self.gallery = nil
        }
    }
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [UIImage], imageAssets: [Image]) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
        
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
        
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [UIImage]) {
        
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
}

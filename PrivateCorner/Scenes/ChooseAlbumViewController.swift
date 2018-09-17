//
//  ChooseAlbumViewController.swift
//  PrivateCorner
//
//  Created by a on 8/29/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import Foundation
import UIKit
import CDAlertView
import Gallery

class ChooseAlbumViewController: BaseViewController, ChooseAlbumViewModelDelegate {
    
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    var viewModel: ChooseAlbumViewModel!
    var gallery: GalleryController!
    var containerView: UIView!
    var progressRing: UICircularProgressRingView!
    var alert: CDAlertView!
    var isUploading: Bool = false
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
    
    func styleUI() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.clear
        containerView.heightAnchor.constraint(equalToConstant: 153.0).isActive = true
        
        progressRing = UICircularProgressRingView(frame: CGRect(x: 35, y: 0, width: 153, height: 153))
        // Change any of the properties you'd like
        let blue = UIColor(hexString: "#3498db")
        progressRing.outerRingColor = blue
        progressRing.outerRingWidth = 8.0
        progressRing.innerRingColor = blue.lighter()
        progressRing.innerRingSpacing = 0
        progressRing.fontColor = blue.darkened()
        containerView.addSubview(progressRing)
    }
    
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
                    Config.tabsToShow = [.imageTab, .videoTab]
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
                    Config.tabsToShow = [.cameraTab]
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
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        DispatchQueue.main.async {
            controller.dismiss(animated: true, completion: nil)
            self.gallery = nil
        }
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
}

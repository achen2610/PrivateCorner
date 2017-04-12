//
//  GalleryPhotoViewController.swift
//  PrivateCorner
//
//  Created by a on 3/30/17.
//  Copyright (c) 2017 MrAChen. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//

import UIKit
import Photos
import ImagePicker

protocol GalleryPhotoViewControllerInput {
    func displayGallery(viewModel: GalleryPhotoScene.GetGalleryPhoto.ViewModel)
}

protocol GalleryPhotoViewControllerOutput {
    func getGallery()
    func uploadPhoto(request: GalleryPhotoScene.UploadPhoto.Request)
}

class GalleryPhotoViewController: UIViewController, GalleryPhotoViewControllerInput {
    
    var output: GalleryPhotoViewControllerOutput!
    var router: GalleryPhotoRouter!
    let imagePickerController = ImagePickerController()
    var items: [Item] = []
    
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    // MARK: Object lifecycle
    
    struct cellIdentifiers {
        static let galleryCell = "galleryCell"
    }
    
    struct cellLayout {
        static let itemsPerRow: CGFloat = 4
        static let sectionInsets: UIEdgeInsets = UIEdgeInsets(top: 1, left: 1, bottom: 0, right: 0)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        GalleryPhotoConfigurator.sharedInstance.configure(viewController: self)
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        configureCollectionViewOnLoad()
        getGalleryPhotoOnLoad()
    }
    
    // MARK: Event handling
    func configureSubviews() {
        self.title = "Gallery"
    }
    
    func configureCollectionViewOnLoad() {
        let nibName = UINib(nibName: "GalleryCell", bundle:Bundle.main)
        galleryCollectionView.register(nibName, forCellWithReuseIdentifier: cellIdentifiers.galleryCell)
    }
    
    func getGalleryPhotoOnLoad() {
        output.getGallery()
    }
    
    @IBAction func clickUploadButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        
        /*
        let alertController = UIAlertController(title: "", message: "Import From", preferredStyle: .actionSheet)
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { (alert) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                let imagePickerController = ImagePickerController()
                imagePickerController.delegate = self
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (alert) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(libraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        */
    }
    
    func selectedPhotoAtIndex(index: Int) {
        router.navigateToPhotoScreen()
    }
    
    func uploadImageToCoreData(images: [UIImage], filenames: [String]) {
        let request = GalleryPhotoScene.UploadPhoto.Request(images: images, filenames: filenames)
        output.uploadPhoto(request: request)
    }
    
    // MARK: Display logic
    func displayGallery(viewModel: GalleryPhotoScene.GetGalleryPhoto.ViewModel) {
        items = viewModel.gallery
        galleryCollectionView.reloadData()
    }
}

//This should be on configurator but for some reason storyboard doesn't detect ViewController's name if placed there
extension GalleryPhotoViewController: GalleryPhotoPresenterOutput {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router.passDataToNextScene(for: segue)
    }
}


extension GalleryPhotoViewController: UIImagePickerControllerDelegate {

}

extension GalleryPhotoViewController: UINavigationControllerDelegate {
    
}

extension GalleryPhotoViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }

    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        var filenames = [String]()
        let assets = imagePicker.stack.assets
        
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        let size: CGSize = CGSize(width: 720, height: 1280)
        
        for asset in assets {
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
                if let info = info {
                    if let filename = (info["PHImageFileURLKey"] as? NSURL)?.lastPathComponent {
                        //do sth with file name
                        filenames.append(filename)
                    }
                    
                }
            }
        }
        
        uploadImageToCoreData(images: images, filenames: filenames)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
}

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
import MessageUI
import DynamicColor
import CoreData
import CDAlertView

class GalleryPhotoViewController: BaseViewController, GalleryPhotoViewModelDelegate {

    var gallery: GalleryController!
    var viewModel: GalleryPhotoViewModel!
    var containerView: UIView!
    var progressRing: UICircularProgressRingView!
    var alert: CDAlertView!
    var isEditMode: Bool = false
    var isUploading: Bool = false
    var isRequestPermission: Bool = false
    
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var selectAllButton: UIBarButtonItem!
    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet weak var moveButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var noImageView: UIView!
    @IBOutlet weak var bottomConstraintCollectionView: NSLayoutConstraint!
    
    // MARK: - Object lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        styleUI()
        configureCollectionViewOnLoad()
        getGalleryPhotoOnLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCollectionViewWhenMoveFile), name: NSNotification.Name(rawValue: Key.SString.notiUpdateGalleryWhenMoveFile), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCollectionView), name: NSNotification.Name(rawValue: Key.SString.notiUpdateGallery), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isHeroEnabled = false
    }
    
    // MARK: - Event handling
    func styleUI() {
        title = viewModel.titleAlbum

        var rect = toolBar.frame
        rect.origin.y += rect.size.height
        toolBar.frame = rect
        toolBar.barTintColor = navigationController?.navigationBar.barTintColor
        
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
        
        noImageView.isHidden = true
    }
    
    func configureCollectionViewOnLoad() {
        let nibName = UINib(nibName: "GalleryCell", bundle:Bundle.main)
        galleryCollectionView.register(nibName, forCellWithReuseIdentifier: viewModel.cellIdentifier())
        galleryCollectionView.alwaysBounceVertical = true
        galleryCollectionView.allowsMultipleSelection = true
        galleryCollectionView.indicatorStyle = .white
    }
    
    func getGalleryPhotoOnLoad() {
        viewModel.getGallery()
    }
    
    @objc func updateCollectionView() {
        viewModel.updateGallery(collectionView: galleryCollectionView)
    }
    
    @objc func updateCollectionViewWhenMoveFile() {
        viewModel.updateGallery(collectionView: galleryCollectionView)
        updateStateEditButton()
        
        alert = CDAlertView(title: nil, message: "Move file success!", type: .success)
        alert.show()
        
        delay(1.0, execute: {
            self.alert.hide(isPopupAnimated: true)
        })
    }
    
    func scrollToBottom(animated: Bool) {
        let numberItems = viewModel.numberOfItemInSection(section: 0)
        if numberItems > 0 {
            galleryCollectionView.scrollToItem(at: NSIndexPath.init(row:numberItems - 1, section: 0) as IndexPath,
                                                    at: .bottom,
                                                    animated: animated)
        }
    }
    
    func updateStateEditButton() {
        if (viewModel.arraySelectedCell.filter{ $0 == true }).count > 0 {
            exportButton.isEnabled = true
            moveButton.isEnabled = true
            deleteButton.isEnabled = true
        } else {
            exportButton.isEnabled = false
            moveButton.isEnabled = false
            deleteButton.isEnabled = false
        }
    }
    
    func updateTitlePhotoSelected() {
        let count = (viewModel.arraySelectedCell.filter{ $0 == true }).count
        if count > 0 {
            title = "\(count) " + (count == 1 ? "Photo" : "Photos") + " Selected"
        } else {
            title = "Select Items"
        }
    }
    
    func alertExport() {
        alert = CDAlertView(title: nil, message: "Do you want to export images to Photo Library?", type: .warning)
        let alertAction = CDAlertViewAction(title: "Export", font: nil, textColor: nil, backgroundColor: nil) { (action) -> Bool in
            var indexSelectedImage = [Int]()
            var index = 0
            for check in self.viewModel.arraySelectedCell {
                if check {
                    indexSelectedImage.append(index)
                }
                index += 1
            }
            
            if indexSelectedImage.count > 0 {
                self.viewModel.exportFile(indexes: indexSelectedImage, type: .PhotoLibrary)
            }
            return true
        }
        alert.add(action: alertAction)
        let cancelAction = CDAlertViewAction(title: "Cancel")
        alert.add(action: cancelAction)
        alert.show()
    }
    
    func copyImages() {
        var indexSelectedImage = [Int]()
        var index = 0
        for check in self.viewModel.arraySelectedCell {
            if check {
                indexSelectedImage.append(index)
            }
            index += 1
        }
        
        if indexSelectedImage.count <= 0 {
            return
        }
        
        viewModel.exportFile(indexes: indexSelectedImage, type: .Copy)
    }
    
    // MARK: - Selector Event
    @IBAction func clickUploadButton(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            
            if SPRequestPermission.isAllowPermissions([.camera, .photoLibrary]) {
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                    self.gallery = GalleryController()
                    self.gallery.delegate = self
                    self.present(self.gallery, animated: true, completion: nil)
                }
            } else {
                self.isRequestPermission = true
                SPRequestPermission.dialog.interactive.present(on: self, with: [.camera, .photoLibrary], dataSource: CustomDataSource(), delegate: self)
                
            }
        }
        let pasteAction = UIAlertAction(title: "Paste", style: .default) { (action) in
            if let data = UserDefaults.standard.value(forKey: "ItemCopy") as? Data {
                if let info = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] {
                    let fromAlbum = AlbumManager.shared.getAlbum(url: info["album"] as! URL)
                    let pasteItems = ItemManager.shared.getItems(urls: info["items"] as! [URL])
                    
                    if let fromAlbum = fromAlbum, pasteItems.count > 0 {
                        self.alert = CDAlertView(title: nil, message: "Paste images processing!", type: .warning)
                        self.alert.customView = self.containerView
                        self.alert.show()
                        
                        self.viewModel.pasteItemToAlbum(pasteItems: pasteItems, fromAlbum: fromAlbum, collectionView: self.galleryCollectionView)
                        
                        return
                    }
                }
            }

            let controller = GlobalMethods.alertController(title: nil, message: "No images copy!", cancelTitle: "Ok")
            self.present(controller, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(pasteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func clickEditMode(_ sender: Any) {
        isEditMode = !isEditMode
        UIView.animate(withDuration: 0.3) {
            if self.isEditMode {
                self.toolBar.alpha = 1.0
                self.addPhotoButton.alpha = 0.0
            } else {
                self.toolBar.alpha = 0.0
                self.addPhotoButton.alpha = 1.0
            }
        }
        
        if isEditMode {
            title = "Select Items"
            navigationItem.setHidesBackButton(true, animated: false)
            
            let barButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(clickEditMode(_:)))
            navigationItem.rightBarButtonItem = barButton
            
            updateStateEditButton()
        } else {
            title = viewModel.titleAlbum
            navigationItem.setHidesBackButton(false, animated: false)
            
            let barButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(clickEditMode(_:)))
            navigationItem.rightBarButtonItem = barButton
            
            if viewModel.numberOfItemInSection(section: 0) > 0 {
                galleryCollectionView.deselectAllItems(section: 0, animated: false)
                
                for index in 0...viewModel.numberOfItemInSection(section: 0) - 1 {
                    viewModel.arraySelectedCell[index] = false
                    
                    if let cell = galleryCollectionView.cellForItem(at: IndexPath(row: index, section: 0))as? GalleryCell {
                        cell.containerView.isHidden = true
                        cell.selectedImageView.isHidden = true
                    }
                }
            }
        }
    }
    
    @IBAction func clickSelectAllButton(_ sender: Any) {
        if isEditMode {
            if viewModel.numberOfItemInSection(section: 0) > 0 {
                for index in 0...viewModel.numberOfItemInSection(section: 0) - 1 {
                    viewModel.arraySelectedCell[index] = true
                    
                    if let cell = galleryCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? GalleryCell {
                        cell.containerView.isHidden = false
                        cell.selectedImageView.isHidden = false
                    }
                }
            }
            
            exportButton.isEnabled = true
            moveButton.isEnabled = true
            deleteButton.isEnabled = true
        }
    }
    
    @IBAction func clickExportButton(_ sender: Any) {
        
        let activityViewController = UIActivityViewController(activityItems: [UIImage()], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.airDrop, .copyToPasteboard, .mail, .message, .postToFacebook, .postToFlickr, .postToTwitter, .postToVimeo, .print, .saveToCameraRoll]
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
        
        
//        let alertController = UIAlertController(title: nil, message: "Export to", preferredStyle: .actionSheet)
//        let cameraAction = UIAlertAction(title: "Photo Library", style: .default) { (alertAction) in
//            self.alertExport()
//        }
//        let emailAction = UIAlertAction(title: "Email", style: .default) { (alertAction) in
//            if MFMailComposeViewController.canSendMail() {
//                var indexSelectedImage = [Int]()
//                var index = 0
//                for check in self.viewModel.arraySelectedCell {
//                    if check {
//                        indexSelectedImage.append(index)
//                    }
//                    index += 1
//                }
//
//                if indexSelectedImage.count <= 0 {
//                    return
//                }
//
//                self.viewModel.exportFile(indexes: indexSelectedImage, type: .Email)
//            }
//        }
//        let copyAction = UIAlertAction(title: "Copy", style: .default) { (alertAction) in
//            self.copyImages()
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alertController.addAction(cameraAction)
//        alertController.addAction(emailAction)
//        alertController.addAction(copyAction)
//        alertController.addAction(cancelAction)
//        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func clickMoveButton(_ sender: Any) {
        var indexSelectedImage = [Int]()
        var index = 0
        for check in viewModel.arraySelectedCell {
            if check {
                indexSelectedImage.append(index)
            }
            index += 1
        }
        
        if indexSelectedImage.count <= 0 {
            return
        }

        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let navi  = mainStoryboard.instantiateViewController(withIdentifier: "MoveFile") as! UINavigationController
        if let controller = navi.visibleViewController as? MoveFileViewController {
            let vm = viewModel.moveFileModel(indexes: indexSelectedImage)
            controller.viewModel = vm
        }

        present(navi, animated: true, completion: nil)
    }
    
    @IBAction func clickDeleteButton(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: "Do you want to delete images?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (deleteAction) in
            var indexSelectedImage = [Int]()
            var index = 0
            for check in self.viewModel.arraySelectedCell {
                if check {
                    indexSelectedImage.append(index)
                }
                index += 1
            }
            
            // Use Diff to delete image
            self.viewModel.deleteItem(indexes: indexSelectedImage, collectionView: self.galleryCollectionView)
            
            // Update array check select cell
            let indexesToRemove = Set(indexSelectedImage.compactMap { $0 })
            self.viewModel.arraySelectedCell = self.viewModel.arraySelectedCell.enumerated().filter { !indexesToRemove.contains($0.offset) }.map { $0.element }
    
            // Update state edit buttons
            self.updateStateEditButton()
            
            // Update state no image label
            if self.viewModel.numberOfItemInSection(section: 0) > 0 {
                self.noImageView.isHidden = true
            } else {
                self.noImageView.isHidden = false
            }
        }
        deleteAction.setValue(UIColor(hexString: "#F71700"), forKey: "titleTextColor")
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    

    // MARK: - GalleryPhotoViewModelDelegate
    func reloadGallery() {
        if isUploading {
            self.alert.hide(isPopupAnimated: false)
            self.alert = CDAlertView(title: nil, message: "Upload success!", type: .success)
            self.alert.show()
            self.progressRing.setProgress(value: 0, animationDuration: 0)
            isUploading = false
            
            delay(1.2, execute: {
                self.alert.hide(isPopupAnimated: true)
            })
            
            DispatchQueue.main.async(execute: {
                self.scrollToBottom(animated: true)
            })
        } else {
            galleryCollectionView.reloadData()
            galleryCollectionView.performBatchUpdates({ }, completion: { (finished) in
                if finished {
                    self.scrollToBottom(animated: false)
                }
            })
        }
        
        if viewModel.numberOfItemInSection(section: 0) > 0 {
            noImageView.isHidden = true
        } else {
            noImageView.isHidden = false
        }
    }
    
    func navigationToPhotoScreen(viewModel: PhotoViewViewModel, indexPath: IndexPath) {
        navigationController?.isHeroEnabled = true
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller  = mainStoryboard.instantiateViewController(withIdentifier: "PhotoView") as! PhotoViewController
        controller.selectedIndex = indexPath
        controller.viewModel = viewModel
        
        navigationController?.pushViewController(controller, animated: true)
    }

    func updateProgressRing(value: CGFloat) {
        DispatchQueue.main.async { 
            self.progressRing.setProgress(value: value, animationDuration: 0.3)
        }
    }

    func exportSuccess() {
        DispatchQueue.main.async {
            self.alert = CDAlertView(title: nil, message: "Export images to Photo Library success!", type: .success)
            self.alert.show()
            
            delay(1.0, execute: {
                self.alert.hide(isPopupAnimated: true)
            })
        }
    }
    
    func sendEmail(emailVC: MFMailComposeViewController) {
        emailVC.mailComposeDelegate = self
        present(emailVC, animated: true, completion: nil)
    }
    
    func copyImagesSuccess() {
        alert = CDAlertView(title: nil, message: "Copy images success!", type: .success)
        alert.show()
        
        delay(1.0, execute: {
            self.alert.hide(isPopupAnimated: true)
        })
        
        if viewModel.numberOfItemInSection(section: 0) > 0 {
            galleryCollectionView.deselectAllItems(section: 0, animated: false)
            
            for index in 0...viewModel.numberOfItemInSection(section: 0) - 1 {
                viewModel.arraySelectedCell[index] = false
                
                if let cell = galleryCollectionView.cellForItem(at: IndexPath(row: index, section: 0))as? GalleryCell {
                    cell.containerView.isHidden = true
                    cell.selectedImageView.isHidden = true
                }
            }
        }
    }
    
    func pasteImagesSuccess() {
        alert.hide(isPopupAnimated: false)
        alert = CDAlertView(title: nil, message: "Paste images success!", type: .success)
        alert.show()
        
        delay(1.2, execute: {
            self.alert.hide(isPopupAnimated: true)
        })
        
        viewModel.arraySelectedCell.removeAll()
        if viewModel.numberOfItemInSection(section: 0) > 0 {
            for _ in 0...viewModel.numberOfItemInSection(section: 0) - 1 {
                viewModel.arraySelectedCell.append(false)
            }
        }
    }
}


extension GalleryPhotoViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [GImage]) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
        isUploading = true
        progressRing.alpha = 1.0
        alert = CDAlertView(title: nil, message: "Upload processing!", type: .warning)
        alert.customView = containerView
        alert.show()
        
        var assets = [PHAsset]()
        for image in images {
            let asset = image.asset
            assets.append(asset);
        }
        
        GImage.resolve(images: images, completion: { [weak self] resolvedImages in
            if let collectionView = self?.galleryCollectionView {
                self?.viewModel.uploadImageToCoreData(images: resolvedImages as! [UIImage], assets: assets, collectionView: collectionView)
            }
        })
        
//        let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
//        DispatchQueue.global().asyncAfter(deadline: when) {
//            // Your code with delay
//            self.viewModel.uploadImageToCoreData(images: images, assets: assets, collectionView: self.galleryCollectionView)
//        }
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: GVideo) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
        isUploading = true
        progressRing.alpha = 1.0
        alert = CDAlertView(title: nil, message: "Upload processing!", type: .warning)
        alert.customView = containerView
        alert.show()

        video.fetchAVAsset { (avasset) in
            video.fetchDuration({ (duration) in
                self.viewModel.uploadVideoToCoreData(video: video, avasset: avasset!, duration: duration, collectionView: self.galleryCollectionView)
            })
        }
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [GImage]) {
        
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
}

extension GalleryPhotoViewController: HeroViewControllerDelegate {
    func heroWillStartAnimatingTo(viewController: UIViewController) {
        if (viewController as? GalleryPhotoViewController) != nil {
            galleryCollectionView.heroModifiers = [.cascade(delta:0.015, direction:.bottomToTop, delayMatchedViews:true)]
        } else if (viewController as? PhotoViewController) != nil {
            if let cell = galleryCollectionView.cellForItem(at: galleryCollectionView.indexPathsForSelectedItems!.first!) {
                galleryCollectionView.heroModifiers = [.cascade(delta: 0.015, direction: .radial(center: cell.center), delayMatchedViews: true)]
                galleryCollectionView.deselectAllItems(section: 0, animated: false)
            }
            navigationController?.heroNavigationAnimationType = .fade
        } else {
            galleryCollectionView.heroModifiers = [.cascade(delta:0.015)]
            navigationController?.heroNavigationAnimationType = .fade
        }

        if let vc = viewController as? PhotoViewController {
            vc.toolBar.heroModifiers = [.fade]
        }
    }
    func heroWillStartAnimatingFrom(viewController: UIViewController) {
        view.heroModifiers = nil
        if (viewController as? GalleryPhotoViewController) != nil {
            galleryCollectionView.heroModifiers = [.cascade(delta:0.015), .delay(0.25)]
            navigationController?.heroNavigationAnimationType = .fade
        } else {
            galleryCollectionView.heroModifiers = [.cascade(delta:0.015)]
            navigationController?.heroNavigationAnimationType = .fade
            addPhotoButton.heroModifiers = [.fade]
        }
        if let vc = viewController as? PhotoViewController,
            let collectionView = vc.collectionView,
            let originalCellIndex = vc.selectedIndex,
            collectionView.indexPathsForVisibleItems.count > 0,
            let currentCellIndex = vc.collectionView?.indexPathsForVisibleItems[0],
            let targetAttribute = galleryCollectionView.layoutAttributesForItem(at: currentCellIndex) {
            galleryCollectionView.heroModifiers = [.cascade(delta:0.015, direction:.inverseRadial(center:targetAttribute.center))]
            if !galleryCollectionView.indexPathsForVisibleItems.contains(currentCellIndex) {
                // make the cell visible
                galleryCollectionView.scrollToItem(at: currentCellIndex,
                                            at: originalCellIndex < currentCellIndex ? .bottom : .top,
                                             animated: false)
            }
        }
    }
}

extension GalleryPhotoViewController: MFMailComposeViewControllerDelegate {
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent:
            let alertController = UIAlertController(title: nil, message: "Send email success", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
        break
        case .cancelled, .saved:
            controller.dismiss(animated: true, completion: nil)
        break
        case .failed:
            let alertController = UIAlertController(title: nil, message: "Send email failed. Please try again!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
        break
        }
    }
    
}

extension GalleryPhotoViewController: SPRequestPermissionEventsDelegate {
    func didHide() {
        isRequestPermission = false
        
        if SPRequestPermission.isAllowPermissions([.camera, .photoLibrary]) {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                self.gallery = GalleryController()
                self.gallery.delegate = self
                self.present(self.gallery, animated: true, completion: nil)
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

class CustomDataSource: SPRequestPermissionDialogInteractiveDataSource {
    
    //override title in dialog view
    override func headerTitle() -> String {
        return "Request Permission!"
    }
}


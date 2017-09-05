import UIKit
import AVFoundation

public protocol GalleryControllerDelegate: class {

  func galleryController(_ controller: GalleryController, didSelectImages images: [UIImage])
  func galleryController(_ controller: GalleryController, didSelectVideo video: Video)
  func galleryController(_ controller: GalleryController, requestLightbox images: [UIImage])
  func galleryControllerDidCancel(_ controller: GalleryController)
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [UIImage], imageAssets: [Image])
}

public class GalleryController: UIViewController, PermissionControllerDelegate {

  lazy var imagesController: ImagesController = self.makeImagesController()
  lazy var cameraController: CameraController = self.makeCameraController()
  lazy var videosController: VideosController = self.makeVideosController()

  enum Page: Int {
    case images, camera, videos
  }

  lazy var pagesController: PagesController = self.makePagesController()
  lazy var permissionController: PermissionController = self.makePermissionController()
  public weak var delegate: GalleryControllerDelegate?
  public let cart = Cart()

  // MARK: - Init

  public required init() {
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Life cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    setup()

    if Permission.hasPermissions {
      showMain()
    } else {
      showPermissionView()
    }
  }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

  public override var prefersStatusBarHidden : Bool {
    return true
  }

  // MARK: - Logic

  public func reload(_ images: [UIImage]) {
    cart.reload(images)
  }

  func showMain() {
    g_addChildController(pagesController)
  }

  func showPermissionView() {
    g_addChildController(permissionController)
  }

  // MARK: - Child view controller

  func makeImagesController() -> ImagesController {
    let controller = ImagesController(cart: cart)
    controller.title = "Gallery.Images.Title".g_localize(fallback: "PHOTOS")

    return controller
  }

  func makeCameraController() -> CameraController {
    let controller = CameraController(cart: cart)
    controller.title = "Gallery.Camera.Title".g_localize(fallback: "CAMERA")

    return controller
  }

  func makeVideosController() -> VideosController {
    let controller = VideosController(cart: cart)
    controller.title = "Gallery.Videos.Title".g_localize(fallback: "VIDEOS")

    return controller
  }

  func makePagesController() -> PagesController {
    var controllers: [UIViewController] = []
    if Config.showsPhotoLibraryTab {
        controllers.append(imagesController)
    }
    if Config.showsCameraTab {
        controllers.append(cameraController)
    }
    if Config.showsVideoTab {
      controllers.append(videosController)
    }

    let controller = PagesController(controllers: controllers)
    controller.selectedIndex = Page.images.rawValue

    return controller
  }

  func makePermissionController() -> PermissionController {
    let controller = PermissionController()
    controller.delegate = self

    return controller
  }

  // MARK: - Setup

  func setup() {
    EventHub.shared.close = { [weak self] in
      if let strongSelf = self {
        strongSelf.delegate?.galleryControllerDidCancel(strongSelf)
      }
    }

    EventHub.shared.doneWithImages = { [weak self] in
      if let strongSelf = self {
//        strongSelf.delegate?.galleryController(strongSelf, didSelectImages: strongSelf.cart.UIImages())
        strongSelf.delegate?.galleryController(strongSelf, didSelectImages: strongSelf.cart.UIImages(), imageAssets: strongSelf.cart.images)
      }
    }

    EventHub.shared.doneWithVideos = { [weak self] in
      if let strongSelf = self, let video = strongSelf.cart.video {
        strongSelf.delegate?.galleryController(strongSelf, didSelectVideo: video)
      }
    }

    EventHub.shared.stackViewTouched = { [weak self] in
      if let strongSelf = self {
        strongSelf.delegate?.galleryController(strongSelf, requestLightbox: strongSelf.cart.UIImages())
      }
    }
  }

  // MARK: - PermissionControllerDelegate

  func permissionControllerDidFinish(_ controller: PermissionController) {
    showMain()
    permissionController.g_removeFromParentController()
  }
}

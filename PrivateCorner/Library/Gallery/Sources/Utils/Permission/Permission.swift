import Foundation
import Photos
import AVFoundation

struct Permission {

  static var hasPermissions: Bool {
    return Photos.hasPermission && Camera.hasPermission
  }

  struct Photos {
    static var hasPermission: Bool {
      return PHPhotoLibrary.authorizationStatus() == .authorized
    }

    static func request(_ completion: @escaping () -> Void) {
      PHPhotoLibrary.requestAuthorization { status in
        completion()
      }
    }
  }

  struct Camera {
    static var hasPermission: Bool {
      return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
    }

    static func request(_ completion: @escaping () -> Void) {
      AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
        completion()
      }
    }
  }
}

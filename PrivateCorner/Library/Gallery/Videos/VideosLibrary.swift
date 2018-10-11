import UIKit
import Photos

class VideosLibrary {

  var items: [GVideo] = []
  var fetchResults: PHFetchResult<PHAsset>?

  // MARK: - Initialization

  init() {

  }

  // MARK: - Logic

  func reload(_ completion: @escaping () -> Void) {
    DispatchQueue.global().async {
      self.reloadSync()
      DispatchQueue.main.async {
        completion()
      }
    }
  }

  fileprivate func reloadSync() {
    fetchResults = PHAsset.fetchAssets(with: .video, options: Utils.fetchOptions())

    items = []
    fetchResults?.enumerateObjects({ (asset, _, _) in
      self.items.append(GVideo(asset: asset))
    })
  }
}


import UIKit
import Photos

class GAlbum {

  let collection: PHAssetCollection
  var items: [GImage] = []

  // MARK: - Initialization

  init(collection: PHAssetCollection) {
    self.collection = collection
  }

  func reload() {
    items = []

    let itemsFetchResult = PHAsset.fetchAssets(in: collection, options: Utils.fetchOptions())
    itemsFetchResult.enumerateObjects({ (asset, count, stop) in
      if asset.mediaType == .image {
        self.items.append(GImage(asset: asset))
      }
    })
  }
}

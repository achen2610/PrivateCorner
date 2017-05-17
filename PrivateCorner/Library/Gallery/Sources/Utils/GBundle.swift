import UIKit

class GBundle {

  static func image(_ named: String) -> UIImage? {
    let bundle = Foundation.Bundle(for: GBundle.self)
    return UIImage(named: "Gallery.bundle/\(named)", in: bundle, compatibleWith: nil)
  }
}

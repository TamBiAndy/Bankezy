

import UIKit
extension UIButton {
    func loadImage(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.setImage(image, for: .normal)
                    }
                }
            } else { return }
        }
    }
    
    func applyShadowForButton(color: UIColor?, alpha: Float?, width: Int?, height: Int?, radius: CGFloat?) {
        self.layer.shadowColor = color?.cgColor
        self.layer.shadowOpacity = alpha ?? 0
        self.layer.shadowOffset = CGSize(width: width ?? 0, height: height ?? 0)
        self.layer.shadowRadius = radius ?? 0
    }
}



//
//  UIImageViewExtension.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 26/08/22.
//  Copyright © 2022 Jonathan Viloria M. All rights reserved.
//

import UIKit

extension UIImageView {
    /// Set an UIImage that will displayed in the UIImageView, the image is retrieved from an URL Request
    /// - Parameters
    ///  - url: URL String from where the information is retrieved
    public func DGPFetchImageByURL(url: String) {
        guard let DGPURL = URL(string: url) else { return }
        DispatchQueue.global().async { [weak self] in
            guard let data = try? Data(contentsOf: DGPURL) else { return }
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
}

extension UISearchBar {
    func updateHeight(height: CGFloat, radius: CGFloat = 8.0) {
        let image: UIImage? = UIImage.imageWithColor(color: UIColor.init(hexFromString: "#e4e6ea"), size: CGSize(width: 1, height: height))
        setSearchFieldBackgroundImage(image, for: .normal)
        for subview in self.subviews {
            for subSubViews in subview.subviews {
                if #available(iOS 13.0, *) {
                    for child in subSubViews.subviews {
                        if let textField = child as? UISearchTextField {
                            textField.layer.cornerRadius = radius
                            textField.clipsToBounds = true
                        }
                    }
                    continue
                }
                if let textField = subSubViews as? UITextField {
                    textField.layer.cornerRadius = radius
                    textField.clipsToBounds = true
                }
            }
        }
    }
}

private extension UIImage {
    static func imageWithColor(color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        guard let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }
}

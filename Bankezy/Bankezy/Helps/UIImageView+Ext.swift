//
//  UIImageView+Ext.swift
//  E-commerce-App
//
//  Created by Andy on 17/10/2024.
//

import UIKit
import RxSwift
import RxCocoa

extension UIImageView {
    
    func loadImage(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            } else { return }
        }
    }
}

extension Reactive where Base: UIImageView {
    var urlImage: Binder<String> {
        Binder(base) { wself, urlString in
            if let url = URL(string: urlString) {
                wself.loadImage(url: url)
            }
        }
    }
}

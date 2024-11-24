//
//  UISearchBar+Ext.swift
//  E-commerce-App
//
//  Created by Andy on 18/10/2024.
//

import UIKit

extension UISearchBar {
    func changeBGcolorOfSearchTextField(color: UIColor) {
        if let textField = self.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = color
            let backgroundView = textField.subviews.first!
            backgroundView.backgroundColor = UIColor.white
            backgroundView.subviews.forEach { $0.removeFromSuperview() }
            backgroundView.layer.cornerRadius = 6
            backgroundView.layer.masksToBounds = true
        }
    }
}


//
//  NavigationBar.swift
//  E-commerce-App
//
//  Created by Andy on 18/10/2024.
//

import UIKit
class CustomNavigationBar: UINavigationBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return .init(width: UIScreen.main.bounds.width, height: 70)
    }
}

extension UINavigationBar {
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return .init(width: UIScreen.main.bounds.width, height: 90)
    }
}

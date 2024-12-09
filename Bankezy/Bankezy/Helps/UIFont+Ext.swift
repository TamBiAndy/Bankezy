//
//  UIFont+Ext.swift
//  E-commerce-App
//
//  Created by Andy on 12/10/2024.
//

import UIKit

extension UIFont {
    
    static func bold(size: CGFloat) -> UIFont {
        .init(name: "Damascus", size: size)!
    }
    
    static func italic(size: CGFloat) -> UIFont {
        .init(name: "DMSans-Italic", size: size)!
    }
    
    static func regular(size: CGFloat) -> UIFont {
        .init(name: "Damascus", size: size)!
    }
    
    static func medium(size: CGFloat) -> UIFont {
        .init(name: "DMSans-Medium", size: size)!
    }
    
    static func light(size: CGFloat) -> UIFont {
        .init(name: "DMSans-Light", size: size)!
    }
    
    static func semiBold(size: CGFloat) -> UIFont {
        .init(name: "DMSans-SemiBold", size: size)!
    }
    static func thin(size: CGFloat) -> UIFont {
        .init(name: "DMSans-Thin", size: size)!
    }
}

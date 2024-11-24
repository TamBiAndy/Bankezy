//
//  UIFont+Ext.swift
//  E-commerce-App
//
//  Created by Andy on 12/10/2024.
//

import UIKit

extension UIFont {
    
    static func bold(size: CGFloat) -> UIFont {
        .init(name: "InriaSans-Bold", size: size)!
    }
    
    static func lightItalic(size: CGFloat) -> UIFont {
        .init(name: "InriaSans-LightItalic", size: size)!
    }
    
    static func regular(size: CGFloat) -> UIFont {
        .init(name: "InriaSans-Regular", size: size)!
    }
    
    static func boldItalic(size: CGFloat) -> UIFont {
        .init(name: "InriaSans-BoldItalic", size: size)!
    }
    
    static func light(size: CGFloat) -> UIFont {
        .init(name: "InriaSans-Light", size: size)!
    }
    
    static func italic(size: CGFloat) -> UIFont {
        .init(name: "InriaSans-Italic", size: size)!
    }
}

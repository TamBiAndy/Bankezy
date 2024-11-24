//
//  UIFont+Ext.swift
//  E-commerce-App
//
//  Created by Andy on 12/10/2024.
//

import UIKit

extension UIFont {
    
    static func bold(size: CGFloat) -> UIFont {
        .init(name: "Montserrat-Bold", size: size)!
    }
    
    static func medium(size: CGFloat) -> UIFont {
        .init(name: "Montserrat-Medium", size: size)!
    }
    
    static func regular(size: CGFloat) -> UIFont {
        .init(name: "Montserrat-Regular", size: size)!
    }
    
    static func semiBold(size: CGFloat) -> UIFont {
        .init(name: "Montserrat-SemiBold", size: size)!
    }
    
    static func light(size: CGFloat) -> UIFont {
        .init(name: "Montserrat-Light", size: size)!
    }
}

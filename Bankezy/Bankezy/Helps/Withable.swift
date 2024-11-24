//
//  Withable.swift
//  E-commerce-App
//
//  Created by Andy on 12/10/2024.
//


import UIKit

protocol Withable {}

extension Withable where Self: NSObject  {
    func with<S>(_ keypath: ReferenceWritableKeyPath<Self, S>, setTo value: S) -> Self {
        self[keyPath: keypath] = value
        
        return self
    }
}

extension UIView: Withable {}


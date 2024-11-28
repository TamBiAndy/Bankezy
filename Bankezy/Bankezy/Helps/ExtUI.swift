//
//  ExtUI.swift
//  Bankezy
//
//  Created by Andy on 26/11/2024.
//

import Foundation
import UIKit


@IBDesignable
extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        set { layer.cornerRadius = newValue }
        get { return layer.cornerRadius     }
    }
    
    @IBInspectable
    var isCircle: Bool {
        set { layer.cornerRadius = self.frame.height/2 }
        get { return true  }
    }
    
    @IBInspectable var borderWidth: Double {
        get {
            return Double(self.layer.borderWidth)
        }
        set {
            self.layer.borderWidth = CGFloat(newValue)
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var spacingAbove: CGFloat {
        get {
            90
        }
        set {
            guard let parentStack = self.superview as? UIStackView else { return }
            
            if let index = parentStack.arrangedSubviews.firstIndex(of: self) {
                let viewAbove = parentStack.arrangedSubviews[index - 1]
                
                parentStack.setCustomSpacing(newValue, after: viewAbove)
            }
            
        }
    }
}

@IBDesignable
extension UITextField {
    @IBInspectable
    var placeholderColor: UIColor? {
        get {
            guard let attributedPlaceholder = attributedPlaceholder else { return nil }
            return attributedPlaceholder.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
        }
        set {
            if let placeholderText = placeholder {
                           let attributes: [NSAttributedString.Key: Any] = [
                               .foregroundColor: newValue ?? UIColor.lightGray
                           ]
                self.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
            }
        }
    }
}

//
//  String Ext.swift
//  E-commerce-App
//
//  Created by Andy on 20/10/2024.
//

import UIKit

extension String {
    func createStrikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        
        // Thiết lập thuộc tính gạch ngang cho toàn bộ chuỗi
        attributeString.addAttribute(.strikethroughStyle,
                                     value: NSUnderlineStyle.single.rawValue,
                                     range: NSRange(location: 0, length: attributeString.length))
        
        return attributeString
    }
    
    func convertDateFormat(formatInput: String, formatOutput: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = self
        
        if let date = inputFormatter.date(from: self) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = formatOutput
            return outputFormatter.string(from: date)
        }
        return nil
    }
    
    func creatReadMoreAttributedText(displayText: String?, toggleText: String?, colorAtt: UIColor?, font: UIFont?) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: displayText ?? "")
        let toggleAttribute = NSAttributedString(string: toggleText ?? "", attributes: [.foregroundColor: colorAtt ?? .black, .font: font ?? .systemFont(ofSize: 12)])
        attributedString.append(toggleAttribute)
        return attributedString
    }
}

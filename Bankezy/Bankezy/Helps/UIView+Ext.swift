//
//  UIView+Ext.swift
//  E-commerce-App
//
//  Created by Andy on 12/10/2024.
//
import UIKit
import SnapKit

extension UIView {
    func addSubViews(_ views: [UIView]) {
        views.forEach(addSubview(_:))
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0)
    {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = alpha
        self.layer.shadowOffset = CGSize(width: x, height: y)
        self.layer.shadowRadius = blur / 2.0
        if spread == 0 {
            self.layer.shadowPath = nil
        } else {
            let dx = -spread
            let rect = self.layer.bounds.insetBy(dx: dx, dy: dx)
            self.layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}

extension UIView {
    enum Point {
           case topLeft
           case centerLeft
           case bottomLeft
           case topCenter
           case center
           case bottomCenter
           case topRight
           case centerRight
           case bottomRight
           var point: CGPoint {
               switch self {
               case .topLeft:
                   return CGPoint(x: 0, y: 0)
               case .centerLeft:
                   return CGPoint(x: 0, y: 0.5)
               case .bottomLeft:
                   return CGPoint(x: 0, y: 1.0)
               case .topCenter:
                   return CGPoint(x: 0.5, y: 0)
               case .center:
                   return CGPoint(x: 0.5, y: 0.5)
               case .bottomCenter:
                   return CGPoint(x: 0.5, y: 1.0)
               case .topRight:
                   return CGPoint(x: 1.0, y: 0.0)
               case .centerRight:
                   return CGPoint(x: 1.0, y: 0.5)
               case .bottomRight:
                   return CGPoint(x: 1.0, y: 1.0)
               }
           }
       }
    
    func addGradientView(
        colors: [CGColor],
        startPoint: Point = .topCenter,
        endPoint: Point = .bottomCenter,
        locations: [NSNumber]
    ) {
        let gradientView = GradientView(
            colors: colors, startPoint: startPoint,
            endPoint: endPoint, locations: locations
        )
        
        self.addSubview(gradientView)
        
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.sendSubviewToBack(gradientView)
    }
    
}

final class GradientView: UIView {
    
    let colors: [CGColor]
    let startPoint: UIView.Point
    let endPoint: UIView.Point
    let locations: [NSNumber]
    
    private let gradientLayer = CAGradientLayer()

    init(
        colors: [CGColor],
        startPoint: UIView.Point,
        endPoint: UIView.Point,
        locations: [NSNumber]
    ) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.locations = locations

        super.init(frame: .zero)
        print("Setting up gradient background")
        setupBGColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("GradientView layoutSubviews - updating frame")
        gradientLayer.frame = self.bounds
       
    }
    
    private func setupBGColor() {
      
        gradientLayer.colors = colors
        gradientLayer.startPoint = startPoint.point
        gradientLayer.endPoint = endPoint.point
        gradientLayer.locations = locations
        print("Gradient layer set up with colors: \(colors), startPoint: \(startPoint.point), endPoint: \(endPoint.point), locations: \(locations)")
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
extension UIView {
    private func addInnerShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        blur: CGFloat = 4,
        x: CGFloat = 0,
        y: CGFloat = 0,
        spread: CGFloat = 0,
        cornerRadius: CGFloat = 10) {
            // Xóa tất cả các layer shadow cũ
            layer.sublayers?.removeAll(where: { $0.name == "innerShadow" })
            
            // Tạo layer cho inner shadow
            let innerShadowLayer = CALayer()
            innerShadowLayer.name = "innerShadow"
            innerShadowLayer.frame = bounds
            innerShadowLayer.cornerRadius = cornerRadius
            innerShadowLayer.backgroundColor = UIColor.clear.cgColor
            
            // Tạo path cho shadow
            let dx = -spread
            let shadowPath = UIBezierPath(ovalIn: bounds.insetBy(dx: dx, dy: dx)).cgPath
            let maskLayer = CAShapeLayer()
            if spread == 0 {
                maskLayer.path = nil
            } else {
                maskLayer.path = shadowPath
            }
            
            // Tạo inner shadow
            let shadowLayer = CALayer()
            shadowLayer.frame = bounds
            shadowLayer.backgroundColor = color.withAlphaComponent(CGFloat(alpha)).cgColor
            shadowLayer.mask = maskLayer
            
            // Thêm shadow layer vào view
            layer.addSublayer(innerShadowLayer)
            layer.addSublayer(shadowLayer)
            
            // Thiết lập shadow
            shadowLayer.shadowColor = color.cgColor
            shadowLayer.shadowOpacity = alpha
            shadowLayer.shadowOffset = CGSize(width: x, height: y)
            shadowLayer.shadowRadius = blur
            shadowLayer.shadowPath = maskLayer.shadowPath
        }
}

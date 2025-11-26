//
//  GradientButton.swift
//  SocialMediaApp
//
//  Created by Munib Hamza on 13/12/2022.
//

import Foundation
import UIKit

@IBDesignable class GradientButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
//        self.titleLabel?.font = fonts
//        self.setTitleColor(.white, for: .normal)
    }
    
//    private let fonts = UIFont(name: "Poppins Medium", size: 16.0) ?? UIFont.systemFont(ofSize: 16)
    
    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [UIColor(named: "startColor")?.cgColor ?? #colorLiteral(red: 0.6148318648, green: 0.4355463386, blue: 0.9520625472, alpha: 1), UIColor(named: "endColor")?.cgColor ?? #colorLiteral(red: 0.9716541171, green: 0.3007429838, blue: 0.5172605515, alpha: 1)]
        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        l.cornerRadius = self.bounds.height/2
        layer.insertSublayer(l, at: 0)
        return l
    }()
}

//
//  GradientView.swift
//  cutestDogs
//
//  Created by Бадый Шагаалан on 19.12.2019.
//  Copyright © 2019 badyi. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var beginColor : UIColor = UIColor.clear //(hexString: "#FFB6C1")
    @IBInspectable var endColor : UIColor = UIColor.clear //white
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        context?.addRect(rect)
        context?.clip()
        let colors : [CGColor] = [beginColor.cgColor, endColor.cgColor]
        var locations : [CGFloat] = [0, 1]
        let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: &locations)
        let startPoint = CGPoint(x: rect.midX, y: rect.maxY)
        let endPoint = CGPoint(x: rect.midX, y: rect.minY)
        context?.drawLinearGradient(grad!, start: startPoint, end: endPoint, options: .drawsBeforeStartLocation)
    }
}

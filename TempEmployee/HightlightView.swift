//
//  HightlightView.swift
//  TempEmployee
//
//  Created by Asad Khan on 3/31/18.
//  Copyright © 2018 Attribe. All rights reserved.
//

import UIKit

@IBDesignable class HightlightView: UIView {

    var highlightedView : UIView!{
        didSet{
            drawHole()
            layoutIfNeeded()
            setNeedsDisplay()
        }
    }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        
    }
 
    func drawHole(){
        
        let radius : CGFloat = 0.0
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.size.width  , height: self.bounds.size.height ), cornerRadius: 0)
        
//        let bgPath = UIBezierPath(roundedRect:self.bounds, cornerRadius: 0)
        
        let circlePath = UIBezierPath(roundedRect: CGRect(x: highlightedView.bounds.midX - radius, y: 0.0, width: 2 * radius, height: 2 * radius), cornerRadius: radius)
        
        path.append(circlePath)
        path.usesEvenOddFillRule = true

        let fillLayer = CAShapeLayer()

        // set initial shape
        fillLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width , height: self.bounds.size.height  )
        fillLayer.path = path.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        
        
        fillLayer.fillColor = UIColor.red.cgColor
        

        self.layer.mask = fillLayer
        
        highlightAnimation(layer : fillLayer)
    }
    
    func highlightAnimation(layer : CAShapeLayer){
        
        let radius = highlightedView.frame.size.width > highlightedView.frame.size.height ? highlightedView.frame.size.width : highlightedView.frame.size.height
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.size.width  , height: self.bounds.size.height ), cornerRadius: 0)
        let padding : CGFloat = 20.0
        
        let circlePath = UIBezierPath(roundedRect: CGRect(x: highlightedView.frame.minX - padding, y: highlightedView.frame.minY - padding, width: highlightedView.frame.size.width + padding * 2, height: highlightedView.frame.size.height + padding * 2), cornerRadius: radius)
        
        path.append(circlePath)
        path.usesEvenOddFillRule = true
        
        
        // 2
        // animate the `path`
       // layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = layer.path
        animation.toValue = path.cgPath
        animation.duration = 0.5// duration is 1 sec
        // 3
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.66, 0, 0.33, 1) // animation curve is Ease Out
        animation.fillMode = kCAFillModeBoth // keep to value after finishing
        animation.isRemovedOnCompletion = false // don't remove after finishing
        
        
        layer.add(animation, forKey: animation.keyPath)
    }
}

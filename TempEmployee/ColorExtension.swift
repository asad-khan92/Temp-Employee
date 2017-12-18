//
//  ColorExtension.swift
//  Temp Provide
//
//  Created by kashif Saeed on 28/05/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation
import UIKit


extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
    class func ShiftHeaderFontColor() -> UIColor {
        return UIColor(hex: "6297FA")
    }
    
    class func blueThemeColor() -> UIColor {
        return UIColor(hex: "5182FA")
    }
}

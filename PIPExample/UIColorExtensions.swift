//
//  UIColorExtensions.swift
//  PIPExample
//
//  Created by Chase Wang on 8/17/16.
//  Copyright © 2016 ocwang. All rights reserved.
//

import UIKit

extension UIColor {
    /*
     * Converts hex integer into UIColor
     *
     * Usage: UIColor(hex: 0xFFFFFF)
     *
     */
    
    private convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
    // MARK: Project Colors
    
    static var pip_darkGray: UIColor {
        return UIColor(hex: 0x666666)
    }
    
    static var pip_gray: UIColor {
        return UIColor(hex: 0xBFBFBF)
    }
    
    static var pip_lightGray: UIColor {
        return UIColor(hex: 0xE6E6E6)
    }
    
    static var pip_offBlack: UIColor {
        return UIColor(hex: 0x444444)
    }
    
    static var pip_offWhite: UIColor {
        return UIColor(hex: 0xF7F7F7)
    }
}

//
//  Utility.swift
//  PIPExample
//
//  Created by Chase Wang on 8/16/16.
//  Copyright © 2016 ocwang. All rights reserved.
//

import UIKit

class Utility {
    static let widthToHeightRatio: CGFloat = (16.0 / 9.0)
    
    class func widthWithDesiredRatio(forHeight height: CGFloat) -> CGFloat {
        let width = height * widthToHeightRatio
        
        return width
    }
    
    class func heightWithDesiredRatio(forWidth width: CGFloat) -> CGFloat {
        let height = width / widthToHeightRatio
        
        return height
    }
}

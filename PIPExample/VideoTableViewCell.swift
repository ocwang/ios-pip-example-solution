//
//  VideoTableViewCell.swift
//  PIPExample
//
//  Created by Chase Wang on 8/17/16.
//  Copyright © 2016 ocwang. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {
    
    // MARK: - Instance Vars
    
    let userPlaceholderSize: CGFloat = 40
    
    // MARK: - Subviews
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var videoPlaceholderView: UIView!
    
    @IBOutlet weak var userPlaceholderView: UIView!
    
    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let layer = userPlaceholderView.layer
        layer.borderColor = UIColor.pip_gray.cgColor
        layer.borderWidth = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let userCornerRadius = userPlaceholderSize / 2
        userPlaceholderView.layer.cornerRadius = userCornerRadius
        
        videoPlaceholderView.layer.cornerRadius = 2
    }
}

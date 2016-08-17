//
//  CommentTableViewCell.swift
//  PIPExample
//
//  Created by Chase Wang on 8/17/16.
//  Copyright © 2016 ocwang. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "CommentTableViewCell"
    
    static let estimatedHeight: CGFloat = 80
    
    // MARK: - Instance Vars
    
    let userPlaceholderSize: CGFloat = 30
    
    // MARK: - Subviews
    
    @IBOutlet weak var userPlaceholderView: UIView!
    
    @IBOutlet weak var commentLabel: UILabel!
    
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
    }
}

//
//  DetailsViewController.swift
//  PIPExample
//
//  Created by Chase Wang on 8/16/16.
//  Copyright © 2016 ocwang. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    // MARK: - Instance Vars
    
    var fakeComments = ["Tootsie roll liquorice pastry jujubes pudding macaroon carrot cake. Biscuit dessert chocolate cake.", "Ice cream soufflé jujubes powder macaroon dragée carrot cake croissant tootsie roll.", "Chocolate chupa chups wafer lemon drops wafer cake powder.", "Oat cake cotton candy pudding carrot cake tiramisu chocolate liquorice. Bonbon halvah muffin donut dragée. Brownie chupa chups sweet pie cake sweet roll tiramisu. Biscuit ice cream caramels."]
    
    // MARK: - Subviews
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CommentTableViewCell.pip_nib(), forCellReuseIdentifier: CommentTableViewCell.reuseIdentifier)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = CommentTableViewCell.estimatedHeight
    }
}

extension DetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fakeComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.reuseIdentifier, for: indexPath) as! CommentTableViewCell
        cell.commentLabel.text = fakeComments[indexPath.row]
        
        return cell
    }
}

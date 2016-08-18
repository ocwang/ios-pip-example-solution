//
//  ContainerViewController.swift
//  PIPExample
//
//  Created by Chase Wang on 8/15/16.
//  Copyright © 2016 ocwang. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    enum VideoPosition: Int {
        case top = 0, bottomRight
    }
    
    // MARK: - Instance Vars
    
    let baseWidthRatio: CGFloat = 0.4
    
    let bottomPadding: CGFloat = 10
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handle(panGesture:)))
        
        return panGesture
    }()
    
    var videoTitles = ["48 Tattoo Artists Who Are Clearly Being Raised Right",
                       "People Who Hate Cats Meet Kittens",
                       "44 Problems Only Muggles Will Understand",
                       "The 28 Illest Puns From Politicians in 2013",
                       "The 22 Greatest Snapchat Filters From LOST"]
    
    var videoWidthConstraint: NSLayoutConstraint!
    var videoTopConstraint: NSLayoutConstraint!
    var videoLeadingConstraint: NSLayoutConstraint!
    var detailsViewTopConstraint: NSLayoutConstraint!
    
    // MARK: - Subviews
    
    @IBOutlet weak var tableView: UITableView!
    
    var videoViewController: VideoViewController!
    
    var detailsViewController: DetailsViewController!

    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Show/Hide Child VCs
    
    
    func presentVideo() {
        removeExistingViewControllerIfNeeded()
        
        addVideoViewController()
        addDetailsViewController()
        
        view.layoutIfNeeded()
        
        videoTopConstraint.constant = 0
        let videoHeight = Utility.heightWithDesiredRatio(forWidth: view.bounds.width)
        detailsViewTopConstraint.constant = videoHeight
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) {
            if $0 {
                self.videoViewController.didMove(toParentViewController: self)
                self.detailsViewController.didMove(toParentViewController: self)
            }
        }
    }
    
    func addVideoViewController() {
        videoViewController = VideoViewController()
        addChildViewController(videoViewController)
        
        let videoView = videoViewController.view!
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.addGestureRecognizer(panGesture)
        
        view.addSubview(videoView)
        
        videoView.widthAnchor.constraint(equalTo: videoView.heightAnchor, multiplier: Utility.widthToHeightRatio).isActive = true
        
        videoWidthConstraint = videoView.widthAnchor.constraint(equalToConstant: view.bounds.width)
        videoWidthConstraint.isActive = true
        
        videoTopConstraint = videoView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.maxY)
        videoTopConstraint.isActive = true
        
        videoLeadingConstraint = videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        videoLeadingConstraint.isActive = true
    }
    
    func addDetailsViewController() {
        detailsViewController = DetailsViewController.pip_instantiateFromNib() as! DetailsViewController
        addChildViewController(detailsViewController)
        
        let detailsView = detailsViewController.view!
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(detailsView)
        
        let width = view.bounds.width
        detailsView.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        let videoHeight = Utility.heightWithDesiredRatio(forWidth: width)
        let detailsViewHeight = view.bounds.height - videoHeight
        detailsView.heightAnchor.constraint(equalToConstant: detailsViewHeight).isActive = true
        
        detailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.minX).isActive = true
        
        detailsViewTopConstraint = detailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.maxY)
        detailsViewTopConstraint.isActive = true
    }
    
    func removeExistingViewControllerIfNeeded() {
        guard let videoViewController = videoViewController,
            let detailsViewController = detailsViewController
            else { return }
        
        remove(viewController: videoViewController)
        remove(viewController: detailsViewController)
    }
    
    func showVideoDetails() {
        detailsViewController.view.isHidden = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.detailsViewController.view.alpha = 1
        })
    }
    
    func hideVideoDetails() {
        detailsViewController.view.isHidden = true
        detailsViewController.view.alpha = 0
    }
    
    func remove(viewController vc: UIViewController) {
        vc.willMove(toParentViewController: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
    }
    
    // MARK: - Pan Gesture
    
    func handle(panGesture sender: UIPanGestureRecognizer) {
        guard let panView = panGesture.view else { return }
        
        let translatedPoint = sender.translation(in: view)
        
        if panGesture.state == .began || panGesture.state == .changed {
            hideVideoDetails()

            translate(panView: panView, withTranslatedPoint: translatedPoint)
            panGesture.setTranslation(.zero, in: view)
        } else if panGesture.state == .ended {
            let currentCenterY = panView.center.y + translatedPoint.y
            let yThreshold = view.bounds.height * 0.4
            
            let finalPosition: VideoPosition = currentCenterY <= yThreshold ? .top : .bottomRight
            animateVideo(toPosition: finalPosition)
        }
    }
    
    func translate(panView: UIView, withTranslatedPoint translatedPoint: CGPoint) {
        let width = view.bounds.width
        let baseWidth = width * baseWidthRatio
        let topDistance = (panView.center.y + translatedPoint.y) - (Utility.heightWithDesiredRatio(forWidth: baseWidth)/2)
        let topDistanceRatio = 1 - (topDistance/(view.frame.height - Utility.heightWithDesiredRatio(forWidth: baseWidth)))
        
        let currentWidth = baseWidth + ((width/2) * topDistanceRatio)
        let currentHeight = Utility.heightWithDesiredRatio(forWidth: currentWidth)
        let currentX = (panView.center.x + translatedPoint.x) - (currentWidth/2)
        let currentY = (panView.center.y + translatedPoint.y) - (currentHeight/2)
        
        self.videoLeadingConstraint.constant = currentX
        self.videoTopConstraint.constant = currentY
        self.videoWidthConstraint.constant = currentWidth
        
        view.setNeedsUpdateConstraints()
        view.layoutIfNeeded()
    }
    
    func animateVideo(toPosition position: VideoPosition) {
        let width = view.bounds.width
        var completionHandler: ((Bool) -> Void)?
        
        switch position {
        case .top:
            self.videoLeadingConstraint.constant = 0
            self.videoTopConstraint.constant = 0
            self.videoWidthConstraint.constant = width
            
            completionHandler = {
                if $0 { self.showVideoDetails() }
            }
        case .bottomRight:
            let bottomWidth: CGFloat = width * baseWidthRatio
            let videoHeight = Utility.heightWithDesiredRatio(forWidth: bottomWidth)
            let bottomX = width - bottomPadding - bottomWidth
            let bottomY = view.frame.height - bottomPadding - videoHeight
            
            self.videoLeadingConstraint.constant = bottomX
            self.videoTopConstraint.constant = bottomY
            self.videoWidthConstraint.constant = bottomWidth
            
            completionHandler = nil
        }
        
        view.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: 0.3,
                       animations: { self.view.layoutIfNeeded() },
                       completion: completionHandler)
    }
}

// MARK: - UITableViewDataSource

extension ContainerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoTableViewCell
        cell.titleLabel.text = videoTitles[indexPath.row]
        
        return cell
    }
}

extension ContainerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentVideo()
    }
}

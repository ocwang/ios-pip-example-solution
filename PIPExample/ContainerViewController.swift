//
//  ContainerViewController.swift
//  PIPExample
//
//  Created by Chase Wang on 8/15/16.
//  Copyright © 2016 ocwang. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    enum VideoPosition {
        case top
        case bottomRight
    }
    
    // MARK: - Instance Vars
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handle(panGesture:)))
        
        return panGesture
    }()
    
    var videoTitles = ["48 Tattoo Artists Who Are Clearly Being Raised Right",
                       "People Who Hate Cats Meet Kittens",
                       "44 Problems Only Muggles Will Understand",
                       "The 28 Illest Puns From Politicians in 2013",
                       "The 22 Greatest Snapchat Filters From LOST"]
    
    // MARK: - Constraints
    
    var videoWidthConstraint: NSLayoutConstraint!
    var videoTopConstraint: NSLayoutConstraint!
    var videoLeadingConstraint: NSLayoutConstraint!
    var detailsViewTopConstraint: NSLayoutConstraint!
    
    // MARK: - Subviews
    
    @IBOutlet weak var tableView: UITableView!
    var videoViewController: VideoViewController!
    var detailsViewController: DetailsViewController!
}

// MARK: - Present/Hide Video

extension ContainerViewController {
    func presentVideo() {
        removeExistingViewControllerIfNeeded()
        addVideoViewController()
        addDetailsViewController()
        
        view.layoutIfNeeded()
        
        videoTopConstraint.constant = 0
        let videoHeight = Utility.heightWithDesiredRatio(forWidth: view.bounds.width)
        detailsViewTopConstraint.constant = videoHeight
        
        let presentAnimation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.view.layoutIfNeeded()
        }
        presentAnimation.addCompletion { (position) in
            if position == .end {
                self.videoViewController.didMove(toParentViewController: self)
                self.detailsViewController.didMove(toParentViewController: self)
            }
        }
        
        presentAnimation.startAnimation()
    }
    
    func showVideoDetails() {
        detailsViewController.view.isHidden = false
        
        UIViewPropertyAnimator(duration: 0.2, curve: UIViewAnimationCurve.easeInOut) {
            self.detailsViewController.view.alpha = 1
            }.startAnimation()
    }
    
    func hideVideoDetails() {
        detailsViewController.view.isHidden = true
        detailsViewController.view.alpha = 0
    }
    
    // MARK: Animate Video to Top/Bottom Position
    
    func animateVideo(toPosition position: VideoPosition) {
        let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.view.layoutIfNeeded()
        }
        
        let width = view.bounds.width
        
        switch position {
        case .top:
            videoLeadingConstraint.constant = 0
            videoTopConstraint.constant = 0
            videoWidthConstraint.constant = width
            
            animation.addCompletion { (position) in
                if position == .end {
                    self.showVideoDetails()
                }
            }
            
        case .bottomRight:
            let videoPadding = VideoViewController.padding
            let bottomWidth: CGFloat = width * VideoViewController.baseWidthRatio
            let videoHeight = Utility.heightWithDesiredRatio(forWidth: bottomWidth)
            let bottomX = width - videoPadding - bottomWidth
            let bottomY = view.frame.height - videoPadding - videoHeight
            
            videoLeadingConstraint.constant = bottomX
            videoTopConstraint.constant = bottomY
            videoWidthConstraint.constant = bottomWidth
        }
        
        view.setNeedsUpdateConstraints()
        animation.startAnimation()
    }
}

// MARK: - Handle Pan Gesture

extension ContainerViewController {
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
        let baseWidth = width * VideoViewController.baseWidthRatio
        let topDistance = (panView.center.y + translatedPoint.y) - (Utility.heightWithDesiredRatio(forWidth: baseWidth)/2)
        let topDistanceRatio = 1 - (topDistance/(view.frame.height - Utility.heightWithDesiredRatio(forWidth: baseWidth)))
        
        let currentWidth = baseWidth + ((width/2) * topDistanceRatio)
        let currentHeight = Utility.heightWithDesiredRatio(forWidth: currentWidth)
        let currentX = (panView.center.x + translatedPoint.x) - (currentWidth / 2)
        let currentY = (panView.center.y + translatedPoint.y) - (currentHeight / 2)
        
        videoLeadingConstraint.constant = currentX
        videoTopConstraint.constant = currentY
        videoWidthConstraint.constant = currentWidth
        
        view.setNeedsUpdateConstraints()
        view.layoutIfNeeded()
    }
}

// MARK: - Add/Remove Child View Controllers

extension ContainerViewController {
    
    // MARK: Add
    
    func addVideoViewController() {
        videoViewController = VideoViewController()
        
        add(childViewController: videoViewController, constraints: { [unowned self] (videoView: UIView) in
            self.videoWidthConstraint = videoView.widthAnchor.constraint(equalToConstant: self.view.bounds.width)
            self.videoTopConstraint = videoView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.maxY)
            self.videoLeadingConstraint = videoView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
            
            NSLayoutConstraint.activate([ videoView.widthAnchor.constraint(equalTo: videoView.heightAnchor, multiplier: Utility.widthToHeightRatio),
                self.videoWidthConstraint,
                self.videoTopConstraint,
                self.videoLeadingConstraint])
            
        }) { [unowned self] (viewController: UIViewController) in
            viewController.view.addGestureRecognizer(self.panGesture)
        }
    }
    
    func addDetailsViewController() {
        detailsViewController = DetailsViewController.pip_instantiateFromNib()
        
        add(childViewController: detailsViewController, constraints: { [unowned self] (detailsView) in
            let width = self.view.bounds.width
            let videoHeight = Utility.heightWithDesiredRatio(forWidth: width)
            let detailsViewHeight = self.view.bounds.height - videoHeight
            self.detailsViewTopConstraint = detailsView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.maxY)
            
            NSLayoutConstraint.activate([detailsView.widthAnchor.constraint(equalToConstant: width),
                detailsView.heightAnchor.constraint(equalToConstant: detailsViewHeight),
                detailsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.minX),
                self.detailsViewTopConstraint])
        })
    }
    
    func add(childViewController viewController: UIViewController, constraints: ((UIView) -> Void)?, completionHandler: ((UIViewController) -> Void)? = nil) {
        addChildViewController(viewController)
        
        let childViewControllerView = viewController.view!
        childViewControllerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childViewControllerView)
        
        constraints?(childViewControllerView)
        completionHandler?(viewController)
    }
    
    // MARK: Remove
    
    func removeExistingViewControllerIfNeeded() {
        guard let videoViewController = videoViewController,
            let detailsViewController = detailsViewController
            else { return }
        
        remove(viewController: videoViewController)
        remove(viewController: detailsViewController)
    }
    
    func remove(viewController vc: UIViewController) {
        vc.willMove(toParentViewController: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
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

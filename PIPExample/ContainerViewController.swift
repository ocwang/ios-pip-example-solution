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
        
        videoViewController = VideoViewController()
        
        addChildViewController(videoViewController)
        let width = view.bounds.width
        let videoHeight = Utility.heightWithDesiredRatio(forWidth: width)
        videoViewController.view.frame = CGRect(x: view.bounds.minX,
                                                y: view.bounds.maxY,
                                                width: width,
                                                height: videoHeight)
        videoViewController.view.addGestureRecognizer(panGesture)
        view.addSubview(videoViewController.view)
        
        detailsViewController = DetailsViewController.pip_instantiateFromNib() as! DetailsViewController
        
        addChildViewController(detailsViewController)
        let detailsViewHeight = view.bounds.height - videoHeight
        detailsViewController.view.frame = CGRect(x: view.bounds.minX,
                                                  y: view.bounds.maxY,
                                                  width: width,
                                                  height: detailsViewHeight)
        view.addSubview(detailsViewController.view)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.videoViewController.view.frame = CGRect(x: 0, y: 0, width: width, height: videoHeight)
            self.detailsViewController.view.frame = CGRect(x: 0, y: videoHeight, width: width, height: detailsViewHeight)
        }) {
            if $0 {
                self.videoViewController.didMove(toParentViewController: self)
                self.detailsViewController.didMove(toParentViewController: self)
            }
        }
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
            
            let translatedFrame = calculateTranslatedFrame(forPanView: panView,
                                                           withTranslatedPoint: translatedPoint)
            panView.frame = translatedFrame
            panGesture.setTranslation(.zero, in: view)
        } else if panGesture.state == .ended {
            let currentCenterY = panView.center.y + translatedPoint.y
            let yThreshold = view.bounds.height * 0.5
            
            let finalPosition: VideoPosition = currentCenterY <= yThreshold ? .top : .bottomRight
            animateVideo(toPosition: finalPosition)
        }
    }
    
    func calculateTranslatedFrame(forPanView panView: UIView, withTranslatedPoint translatedPoint: CGPoint) -> CGRect {
        let width = view.bounds.width
        let baseWidth = width * baseWidthRatio
        let topDistance = (panView.center.y + translatedPoint.y) - (Utility.heightWithDesiredRatio(forWidth: baseWidth)/2)
        let topDistanceRatio = 1 - (topDistance/(view.frame.height - Utility.heightWithDesiredRatio(forWidth: baseWidth)))
        
        let currentWidth = baseWidth + ((width/2) * topDistanceRatio)
        let currentHeight = Utility.heightWithDesiredRatio(forWidth: currentWidth)
        let currentX = (panView.center.x + translatedPoint.x) - (currentWidth/2)
        let currentY = (panView.center.y + translatedPoint.y) - (currentHeight/2)
        
        return CGRect(x: currentX, y: currentY, width: currentWidth, height: currentHeight)
    }
    
    func animateVideo(toPosition position: VideoPosition) {
        let width = view.bounds.width
        var videoHeight: CGFloat
        var videoFrame: CGRect
        var completionHandler: ((Bool) -> Void)?
        
        switch position {
        case .top:
            videoHeight = Utility.heightWithDesiredRatio(forWidth: width)
            videoFrame = CGRect(x: 0, y: 0, width: width, height: videoHeight)
            completionHandler = {
                if $0 {
                    self.showVideoDetails()
                }
            }
        case .bottomRight:
            let bottomWidth: CGFloat = width * baseWidthRatio
            videoHeight = Utility.heightWithDesiredRatio(forWidth: bottomWidth)
            let bottomX = width - bottomPadding - bottomWidth
            let bottomY = view.frame.height - bottomPadding - videoHeight
            videoFrame = CGRect(x: bottomX, y: bottomY, width: bottomWidth, height: videoHeight)
            completionHandler = nil
        }
        
        animateVideo(toFrame: videoFrame, withCompletion: completionHandler)
    }
    
    func animateVideo(toFrame frame: CGRect, withCompletion completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: 0.3,
                       animations: { self.videoViewController.view.frame = frame },
                       completion: completion)
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

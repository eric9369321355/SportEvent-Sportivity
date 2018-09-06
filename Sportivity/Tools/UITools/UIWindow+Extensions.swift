//
//  UIWindow+RootViewController.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 17/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit

extension UIWindow {
    func set(rootViewController newRootViewController: UIViewController) {
        
        let previousViewController = rootViewController
        
        let transition = CATransition()
        transition.delegate = self
        transition.type = kCATransitionFade
        
        // Add the transition
        layer.add(transition, forKey: kCATransition)
        
        rootViewController = newRootViewController
        
        // Update status bar appearance using the new view controllers appearance - animate if needed
        if UIView.areAnimationsEnabled {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                newRootViewController.setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            newRootViewController.setNeedsStatusBarAppearanceUpdate()
        }
        
        if let transitionViewClass = NSClassFromString("UITransitionView") {
            for subview in subviews where subview.isKind(of: transitionViewClass) {
                subview.removeFromSuperview()
            }
        }
        if let presentedPrevious = previousViewController?.presentedViewController {
            // Allow the view controller to be deallocated
            presentedPrevious.dismiss(animated: false) {
                // Remove the root view in case its still showing
                presentedPrevious.view.removeFromSuperview()
            }
        }
        
        if let previousViewController = previousViewController {
            // Allow the view controller to be deallocated
            previousViewController.dismiss(animated: false) {
                // Remove the root view in case its still showing
                previousViewController.view.removeFromSuperview()
            }
        }
    }
}

extension UIWindow: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag == true, self.subviews.count > 1 else { return }
        if let layoutContainerClass = NSClassFromString("UILayoutContainerView"), let transitionViewClass = NSClassFromString("UITransitionView") {
            for layoutContainer in self.subviews where layoutContainer.isKind(of: layoutContainerClass) {
                for subview in layoutContainer.subviews where subview.isKind(of: transitionViewClass) {
                    layoutContainer.removeFromSuperview()
                }
            }
        }
    }
}

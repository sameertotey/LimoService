//
//  ModalPresentationTransitionVendor.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/4/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class ModalPresentationTransitionVendor: NSObject, UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        let presentationController = MenuPresentationController(presentedViewController: presented, presentingViewController: source)
        return presentationController
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = ModalTransitionAnimator()
        animator.duration = 0.55
        animator.presenting = true
//        animator.finalScale = 0.9
        return animator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = ModalTransitionAnimator()
        animator.duration = 0.3
        animator.presenting = false
        return animator
    }
}


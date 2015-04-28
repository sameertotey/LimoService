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
        let presentationController: UIPresentationController?
        if source is MainMenuViewController {
            presentationController = nil
        } else {
            presentationController = MenuPresentationController(presentedViewController: presented, presentingViewController: source)
        }
        return presentationController
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animator: BaseTransitionAnimator
        if source is MainMenuViewController {
            animator = FromMainMenuTransitionAnimator()
            animator.finalScale = 0.8
        } else {
            animator = ModalTransitionAnimator()
            animator.finalScale = 0.9
        }
        animator.duration = 0.65
        animator.presenting = true
        return animator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animator: BaseTransitionAnimator
        if dismissed is MainMenuViewController {
            animator = ModalTransitionAnimator()
        } else {
            animator = FromMainMenuTransitionAnimator()
        }
        animator.duration = 0.35
        animator.presenting = false
        return animator
    }
}


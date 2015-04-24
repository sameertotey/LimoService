//
//  ModalTransitionAnimator.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/4/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class ModalTransitionAnimator: BaseTransitionAnimator, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
//        // all animations take place here, force unwrap the view controller
//        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
//        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
//                
//        let containerView = transitionContext.containerView()
//        
//        let animationDuration = transitionDuration(transitionContext)
//        
//        if presenting {
//            fromViewController.view.userInteractionEnabled = false
//            toViewController.view.transform = CGAffineTransformMakeScale(initialScale, initialScale)
//            toViewController.view.layer.shadowColor = UIColor.blackColor().CGColor
//            toViewController.view.layer.shadowOffset = CGSizeMake(0.0, 2.0)
//            toViewController.view.layer.shadowOpacity = 0.3
//            toViewController.view.layer.cornerRadius = 4.0
//            toViewController.view.clipsToBounds = true
//            
//            containerView.addSubview(toViewController.view)
//            
//            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
//                toViewController.view.transform = CGAffineTransformMakeScale(self.finalScale, self.finalScale)
//                containerView.addSubview(toViewController.view)
//                fromViewController.view.alpha = 0.5
//                }, completion: { (finished) -> Void in
//                    transitionContext.completeTransition(finished)
//            })
//
//        } else {
//            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
//                fromViewController.view.transform = CGAffineTransformMakeScale(self.initialScale, self.initialScale)
//                toViewController.view.alpha = 1.0
//                }, completion: { (finished) -> Void in
//                    toViewController.view.userInteractionEnabled = true
//                    fromViewController.view.removeFromSuperview()
//                    transitionContext.completeTransition(finished)
//            })
//
//        }
        // Here, we perform the animations necessary for the transition
        
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let fromView = fromVC.view
        let toVC   = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toView = toVC.view
        
        let containerView = transitionContext.containerView()
        
        var isPresentation = presenting
        
        if isPresentation {
            containerView.addSubview(toView)
        }
        
        let animatingVC = isPresentation ? toVC : fromVC
        let animatingView = animatingVC.view
        
        let appearedFrame = transitionContext.finalFrameForViewController(animatingVC)
        // Our dismissed frame is the same as our appeared frame, but off the left edge of the container
        var dismissedFrame = appearedFrame
        dismissedFrame.origin.x -=  dismissedFrame.size.width
        
        let initialFrame = isPresentation ? dismissedFrame : appearedFrame
        let finalFrame = isPresentation ? appearedFrame : dismissedFrame
        
        animatingView.frame = initialFrame
        
        // Animate using the duration from -transitionDuration:
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 300.0, initialSpringVelocity: 5.0, options: .AllowUserInteraction | .BeginFromCurrentState, animations: { () -> Void in
            animatingView.frame = finalFrame
        }) { (finished) -> Void in
            // If we're dismissing, remove the presented view from the hierarchy
            if !isPresentation {
                fromView.removeFromSuperview()
            }
            transitionContext.completeTransition(finished)
        }
        
    }
    
    func animationEnded(transitionCompleted: Bool) {
        // cleanup after animation ended
    }
    
      
}

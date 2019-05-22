//
//  SideTransition.swift
//  RayMessenger
//
//  Created by Steve Rustom on 5/22/19.
//  Copyright © 2019 Steve Rustom. All rights reserved.
//
//
//  SideMenuManager.swift
//
//  Created by Jon Kent on 12/6/15.
//  Copyright © 2015 Jon Kent. All rights reserved.
//

import UIKit

open class SideTransition: UIPercentDrivenInteractiveTransition {

    fileprivate var presenting = false
    fileprivate var interactive = false
    fileprivate weak var originalSuperview: UIView?
    fileprivate weak var activeGesture: UIGestureRecognizer?
    fileprivate var switchsides = false {
        didSet {
            if switchsides {
                cancel()
            }
        }
    }
    fileprivate var sideWidth: CGFloat {
        let overriddenWidth = sideViewController?.sideWidth ?? 0
        if overriddenWidth > CGFloat.ulpOfOne {
            return overriddenWidth
        }
        return sideManager.sideWidth
    }
    internal weak var sideManager: SideManager!
    internal weak var mainViewController: UIViewController?
    internal weak var sideViewController: UISideNavigationController? {
        return presentDirection == .left ? sideManager.sideLeftNavigationController : sideManager.sideRightNavigationController
    }
    internal var presentDirection: UIRectEdge = .left
    internal weak var tapView: UIView? {
        didSet {
            guard let tapView = tapView else {
                return
            }

            tapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            let exitPanGesture = UIPanGestureRecognizer()
            exitPanGesture.addTarget(self, action:#selector(SideTransition.handleHideSidePan(_:)))
            let exitTapGesture = UITapGestureRecognizer()
            exitTapGesture.addTarget(self, action: #selector(SideTransition.handleHideSideTap(_:)))
            tapView.addGestureRecognizer(exitPanGesture)
            tapView.addGestureRecognizer(exitTapGesture)
        }
    }
    internal weak var statusBarView: UIView? {
        didSet {
            guard let statusBarView = statusBarView else {
                return
            }

            statusBarView.backgroundColor = sideManager.sideAnimationBackgroundColor ?? UIColor.black
            statusBarView.isUserInteractionEnabled = false
        }
    }

    required public init(sideManager: SideManager) {
        super.init()

        NotificationCenter.default.addObserver(self, selector:#selector(handleNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(handleNotification), name: UIApplication.willChangeStatusBarFrameNotification, object: nil)
        self.sideManager = sideManager
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    fileprivate static var visibleViewController: UIViewController? {
        return getVisibleViewController(forViewController: UIApplication.shared.keyWindow?.rootViewController)
    }

    fileprivate class func getVisibleViewController(forViewController: UIViewController?) -> UIViewController? {
        if let navigationController = forViewController as? UINavigationController {
            return getVisibleViewController(forViewController: navigationController.visibleViewController)
        }
        if let tabBarController = forViewController as? UITabBarController {
            return getVisibleViewController(forViewController: tabBarController.selectedViewController)
        }
        if let splitViewController = forViewController as? UISplitViewController {
            return getVisibleViewController(forViewController: splitViewController.viewControllers.last)
        }
        if let presentedViewController = forViewController?.presentedViewController {
            return getVisibleViewController(forViewController: presentedViewController)
        }

        return forViewController
    }

    @objc internal func handlePresentsideLeftScreenEdge(_ edge: UIScreenEdgePanGestureRecognizer) {
        presentDirection = .left
        handlePresentsidePan(edge)
    }

    @objc internal func handlePresentsideRightScreenEdge(_ edge: UIScreenEdgePanGestureRecognizer) {
        presentDirection = .right
        handlePresentsidePan(edge)
    }

    @objc internal func handlePresentsidePan(_ pan: UIPanGestureRecognizer) {
        if activeGesture == nil {
            activeGesture = pan
        } else if pan != activeGesture {
            pan.isEnabled = false
            pan.isEnabled = true
            return
        } else if pan.state != .began && pan.state != .changed {
            activeGesture = nil
        }

        // how much distance have we panned in reference to the parent view?
        guard let view = mainViewController?.view ?? pan.view else {
            return
        }

        let transform = view.transform
        view.transform = .identity
        let translation = pan.translation(in: pan.view!)
        view.transform = transform

        // do some math to translate this to a percentage based value
        if !interactive {
            if translation.x == 0 {
                return // not sure which way the user is swiping yet, so do nothing
            }

            if !(pan is UIScreenEdgePanGestureRecognizer) {
                presentDirection = translation.x > 0 ? .left : .right
            }

            if let sideViewController = sideViewController, let visibleViewController = SideTransition.visibleViewController {
                interactive = true
                visibleViewController.present(sideViewController, animated: true, completion: nil)
            } else {
                return
            }
        }

        let direction: CGFloat = presentDirection == .left ? 1 : -1
        let distance = translation.x / sideWidth
        // now lets deal with different states that the gesture recognizer sends
        switch (pan.state) {
        case .began, .changed:
            if pan is UIScreenEdgePanGestureRecognizer {
                update(min(distance * direction, 1))
            } else if distance > 0 && presentDirection == .right && sideManager.sideLeftNavigationController != nil {
                presentDirection = .left
                switchsides = true
            } else if distance < 0 && presentDirection == .left && sideManager.sideRightNavigationController != nil {
                presentDirection = .right
                switchsides = true
            } else {
                update(min(distance * direction, 1))
            }
        default:
            interactive = false
            view.transform = .identity
            let velocity = pan.velocity(in: pan.view!).x * direction
            view.transform = transform
            if velocity >= 100 || velocity >= -50 && abs(distance) >= 0.5 {
                finish()
            } else {
                cancel()
            }
        }
    }

    @objc internal func handleHideSidePan(_ pan: UIPanGestureRecognizer) {
        if activeGesture == nil {
            activeGesture = pan
        } else if pan != activeGesture {
            pan.isEnabled = false
            pan.isEnabled = true
            return
        }

        let translation = pan.translation(in: pan.view!)
        let direction:CGFloat = presentDirection == .left ? -1 : 1
        let distance = translation.x / sideWidth * direction

        switch (pan.state) {

        case .began:
            interactive = true
            mainViewController?.dismiss(animated: true, completion: nil)
        case .changed:
            update(max(min(distance, 1), 0))
        default:
            interactive = false
            let velocity = pan.velocity(in: pan.view!).x * direction
            if velocity >= 100 || velocity >= -50 && distance >= 0.5 {
                finish()
                activeGesture = nil
            } else {
                cancel()
                activeGesture = nil
            }
        }
    }

    @objc internal func handleHideSideTap(_ tap: UITapGestureRecognizer) {
        sideViewController?.dismiss(animated: true, completion: nil)
    }

    @discardableResult internal func hideSideStart() -> SideTransition {
        guard let sideView = sideViewController?.view,
            let mainView = mainViewController?.view else {
                return self
        }

        mainView.transform = .identity
        mainView.alpha = 1
        mainView.frame.origin = .zero
        sideView.transform = .identity
        sideView.frame.origin.y = 0
        sideView.frame.size.width = sideWidth
        sideView.frame.size.height = mainView.frame.height // in case status bar height changed
        var statusBarFrame = UIApplication.shared.statusBarFrame
        let statusBarOffset = SideManager.appScreenRect.size.height - mainView.frame.maxY
        // For in-call status bar, height is normally 40, which overlaps view. Instead, calculate height difference
        // of view and set height to fill in remaining space.
        if statusBarOffset >= CGFloat.ulpOfOne {
            statusBarFrame.size.height = statusBarOffset
        }
        statusBarView?.frame = statusBarFrame
        statusBarView?.alpha = 0

        switch sideManager.sidePresentMode {

        case .viewSlideOut:
            sideView.alpha = 1 - sideManager.sideAnimationFadeStrength
            sideView.frame.origin.x = presentDirection == .left ? 0 : mainView.frame.width - sideWidth
            sideView.transform = CGAffineTransform(scaleX: sideManager.sideAnimationTransformScaleFactor, y: sideManager.sideAnimationTransformScaleFactor)

        case .viewSlideInOut, .sideSlideIn:
            sideView.alpha = 1
            sideView.frame.origin.x = presentDirection == .left ? -sideWidth : mainView.frame.width

        case .sideDissolveIn:
            sideView.alpha = 0
            sideView.frame.origin.x = presentDirection == .left ? 0 : mainView.frame.width - sideWidth
        }

        return self
    }

    @discardableResult internal func hideSideComplete() -> SideTransition {
        let sideView = sideViewController?.view
        let mainView = mainViewController?.view

        tapView?.removeFromSuperview()
        statusBarView?.removeFromSuperview()
        mainView?.motionEffects.removeAll()
        mainView?.layer.shadowOpacity = 0
        sideView?.layer.shadowOpacity = 0
        if let topNavigationController = mainViewController as? UINavigationController {
            topNavigationController.interactivePopGestureRecognizer!.isEnabled = true
        }
        if let originalSuperview = originalSuperview, let mainView = mainViewController?.view {
            originalSuperview.addSubview(mainView)
            let y = originalSuperview.bounds.height - mainView.frame.size.height
            mainView.frame.origin.y = max(y, 0)
        }

        originalSuperview = nil
        mainViewController = nil

        return self
    }

    @discardableResult internal func presentsideStart() -> SideTransition {
        guard let sideView = sideViewController?.view,
            let mainView = mainViewController?.view else {
                return self
        }

        sideView.alpha = 1
        sideView.transform = .identity
        sideView.frame.size.width = sideWidth
        let size = SideManager.appScreenRect.size
        sideView.frame.origin.x = presentDirection == .left ? 0 : size.width - sideWidth
        mainView.transform = .identity
        mainView.frame.size.width = size.width
        let statusBarOffset = size.height - sideView.bounds.height
        mainView.bounds.size.height = size.height - max(statusBarOffset, 0)
        mainView.frame.origin.y = 0
        var statusBarFrame = UIApplication.shared.statusBarFrame
        // For in-call status bar, height is normally 40, which overlaps view. Instead, calculate height difference
        // of view and set height to fill in remaining space.
        if statusBarOffset >= CGFloat.ulpOfOne {
            statusBarFrame.size.height = statusBarOffset
        }
        tapView?.transform = .identity
        tapView?.bounds = mainView.bounds
        statusBarView?.frame = statusBarFrame
        statusBarView?.alpha = 1

        switch sideManager.sidePresentMode {

        case .viewSlideOut, .viewSlideInOut:
            mainView.layer.shadowColor = sideManager.sideShadowColor.cgColor
            mainView.layer.shadowRadius = sideManager.sideShadowRadius
            mainView.layer.shadowOpacity = sideManager.sideShadowOpacity
            mainView.layer.shadowOffset = CGSize(width: 0, height: 0)
            let direction:CGFloat = presentDirection == .left ? 1 : -1
            mainView.frame.origin.x = direction * sideView.frame.width

        case .sideSlideIn, .sideDissolveIn:
            if sideManager.sideBlurEffectStyle == nil {
                sideView.layer.shadowColor = sideManager.sideShadowColor.cgColor
                sideView.layer.shadowRadius = sideManager.sideShadowRadius
                sideView.layer.shadowOpacity = sideManager.sideShadowOpacity
                sideView.layer.shadowOffset = CGSize(width: 0, height: 0)
            }
            mainView.frame.origin.x = 0
        }

        if sideManager.sidePresentMode != .viewSlideOut {
            mainView.transform = CGAffineTransform(scaleX: sideManager.sideAnimationTransformScaleFactor, y: sideManager.sideAnimationTransformScaleFactor)
            if sideManager.sideAnimationTransformScaleFactor > 1 {
                tapView?.transform = mainView.transform
            }
            mainView.alpha = 1 - sideManager.sideAnimationFadeStrength
        }

        return self
    }

    @discardableResult internal func presentsideComplete() -> SideTransition {
        switch sideManager.sidePresentMode {
        case .sideSlideIn, .sideDissolveIn, .viewSlideInOut:
            if let mainView = mainViewController?.view, sideManager.sideParallaxStrength != 0 {
                let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
                horizontal.minimumRelativeValue = -sideManager.sideParallaxStrength
                horizontal.maximumRelativeValue = sideManager.sideParallaxStrength

                let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
                vertical.minimumRelativeValue = -sideManager.sideParallaxStrength
                vertical.maximumRelativeValue = sideManager.sideParallaxStrength

                let group = UIMotionEffectGroup()
                group.motionEffects = [horizontal, vertical]
                mainView.addMotionEffect(group)
            }
        case .viewSlideOut: break;
        }
        if let topNavigationController = mainViewController as? UINavigationController {
            topNavigationController.interactivePopGestureRecognizer!.isEnabled = false
        }

        return self
    }

    @objc internal func handleNotification(notification: NSNotification) {
        guard sideViewController?.presentedViewController == nil &&
            sideViewController?.presentingViewController != nil else {
                return
        }

        if let originalSuperview = originalSuperview,
            let mainViewController = mainViewController,
            sideManager.sideDismissWhenBackgrounded {
            originalSuperview.addSubview(mainViewController.view)
        }

        if notification.name == UIApplication.didEnterBackgroundNotification {
            if sideManager.sideDismissWhenBackgrounded {
                hideSideStart().hideSideComplete()
                sideViewController?.dismiss(animated: false, completion: nil)
            }
            return
        }

        UIView.animate(withDuration: sideManager.sideAnimationDismissDuration,
                       delay: 0,
                       usingSpringWithDamping: sideManager.sideAnimationUsingSpringWithDamping,
                       initialSpringVelocity: sideManager.sideAnimationInitialSpringVelocity,
                       options: sideManager.sideAnimationOptions,
                       animations: {
                        self.hideSideStart()
        }) { (finished) -> Void in
            self.hideSideComplete()
            self.sideViewController?.dismiss(animated: false, completion: nil)
        }
    }

}

extension SideTransition: UIViewControllerAnimatedTransitioning {

    // animate a change from one viewcontroller to another
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        completionCurve = sideManager.sideAnimationCompletionCurve

        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView
        // prevent any other side gestures from firing
        container.isUserInteractionEnabled = false

        if let sideBackgroundColor = sideManager.sideAnimationBackgroundColor {
            container.backgroundColor = sideBackgroundColor
        }

        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!

        // assign references to our side view controller and the 'bottom' view controller from the tuple
        // remember that our sideViewController will alternate between the from and to view controller depending if we're presenting or dismissing
        mainViewController = presenting ? fromViewController : toViewController

        let sideView = sideViewController!.view!
        let topView = mainViewController!.view!

        // prepare side items to slide in
        if presenting {
            originalSuperview = topView.superview

            // add the both views to our view controller
            switch sideManager.sidePresentMode {
            case .viewSlideOut, .viewSlideInOut:
                container.addSubview(sideView)
                container.addSubview(topView)
            case .sideSlideIn, .sideDissolveIn:
                container.addSubview(topView)
                container.addSubview(sideView)
            }

            if sideManager.sideFadeStatusBar {
                let statusBarView = UIView()
                self.statusBarView = statusBarView
                container.addSubview(statusBarView)
            }

            hideSideStart()
        }

        let animate = {
            if self.presenting {
                self.presentsideStart()
            } else {
                self.hideSideStart()
            }
        }

        let complete = {
            container.isUserInteractionEnabled = true

            // tell our transitionContext object that we've finished animating
            if transitionContext.transitionWasCancelled {
                let viewControllerForPresentedside = self.mainViewController

                if self.presenting {
                    self.hideSideComplete()
                } else {
                    self.presentsideComplete()
                }

                transitionContext.completeTransition(false)

                if self.switchsides {
                    self.switchsides = false
                    viewControllerForPresentedside?.present(self.sideViewController!, animated: true, completion: nil)
                }

                return
            }

            if self.presenting {
                self.presentsideComplete()
                transitionContext.completeTransition(true)
                switch self.sideManager.sidePresentMode {
                case .viewSlideOut, .viewSlideInOut:
                    container.addSubview(topView)
                case .sideSlideIn, .sideDissolveIn:
                    container.insertSubview(topView, at: 0)
                }
                if !self.sideManager.sidePresentingViewControllerUserInteractionEnabled {
                    let tapView = UIView()
                    container.insertSubview(tapView, aboveSubview: topView)
                    tapView.bounds = container.bounds
                    tapView.center = topView.center
                    if self.sideManager.sideAnimationTransformScaleFactor > 1 {
                        tapView.transform = topView.transform
                    }
                    self.tapView = tapView
                }
                if let statusBarView = self.statusBarView {
                    container.bringSubviewToFront(statusBarView)
                }

                return
            }

            self.hideSideComplete()
            transitionContext.completeTransition(true)
            sideView.removeFromSuperview()
        }

        // perform the animation!
        let duration = transitionDuration(using: transitionContext)
        if interactive {
            UIView.animate(withDuration: duration,
                           delay: duration, // HACK: If zero, the animation briefly flashes in iOS 11.
                options: .curveLinear,
                animations: {
                    animate()
            }, completion: { (finished) in
                complete()
            })
        } else {
            UIView.animate(withDuration: duration,
                           delay: 0,
                           usingSpringWithDamping: sideManager.sideAnimationUsingSpringWithDamping,
                           initialSpringVelocity: sideManager.sideAnimationInitialSpringVelocity,
                           options: sideManager.sideAnimationOptions,
                           animations: {
                            animate()
            }) { (finished) -> Void in
                complete()
            }
        }
    }

    // return how many seconds the transiton animation will take
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if interactive {
            return sideManager.sideAnimationCompleteGestureDuration
        }
        return presenting ? sideManager.sideAnimationPresentDuration : sideManager.sideAnimationDismissDuration
    }

    open override func update(_ percentComplete: CGFloat) {
        guard !switchsides else {
            return
        }

        super.update(percentComplete)
    }

}

extension SideTransition: UIViewControllerTransitioningDelegate {

    // return the animator when presenting a viewcontroller
    // rememeber that an animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        presentDirection = presented == sideManager.sideLeftNavigationController ? .left : .right
        return self
    }

    // return the animator used when dismissing from a viewcontroller
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presenting = false
        return self
    }

    open func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // if our interactive flag is true, return the transition manager object
        // otherwise return nil
        return interactive ? self : nil
    }

    open func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactive ? self : nil
    }

}

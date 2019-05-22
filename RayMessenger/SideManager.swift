//
//  SideManager.swift
//  RayMessenger
//
//  Created by Steve Rustom on 5/22/19.
//  Copyright © 2019 Steve Rustom. All rights reserved.
//

/* Example usage:
 // Define the sides
 sideManager.sideLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftsideNavigationController") as? UIsideNavigationController
 sideManager.sideRightNavigationController = storyboard!.instantiateViewController(withIdentifier: "RightsideNavigationController") as? UIsideNavigationController

 // Enable gestures. The left and/or right sides must be set up above for these to work.
 // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
 sideManager.sideAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
 sideManager.sideAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
 */
import Foundation
import UIKit

@objcMembers
open class SideManager: NSObject {
    static let shared = SideManager()
    public override init() {
        super.init()
        transition = SideTransition(sideManager: self)
    }

    @objc public enum SidePushStyle: Int {
        case defaultBehavior,
        popWhenPossible,
        replace,
        preserve,
        preserveAndHideBackButton,
        subside
    }

    @objc public enum SidePresentMode: Int {
        case sideSlideIn,
        viewSlideOut,
        viewSlideInOut,
        sideDissolveIn
    }

    // Bounds which has been allocated for the app on the whole device screen
    internal static var appScreenRect: CGRect {
        let appWindowRect = UIApplication.shared.keyWindow?.bounds ?? UIWindow().bounds
        return appWindowRect
    }

    /**
     The push style of the side.

     There are six modes in sidePushStyle:
     - defaultBehavior: The view controller is pushed onto the stack.
     - popWhenPossible: If a view controller already in the stack is of the same class as the pushed view controller, the stack is instead popped back to the existing view controller. This behavior can help users from getting lost in a deep navigation stack.
     - preserve: If a view controller already in the stack is of the same class as the pushed view controller, the existing view controller is pushed to the end of the stack. This behavior is similar to a UITabBarController.
     - preserveAndHideBackButton: Same as .preserve and back buttons are automatically hidden.
     - replace: Any existing view controllers are released from the stack and replaced with the pushed view controller. Back buttons are automatically hidden. This behavior is ideal if view controllers require a lot of memory or their state doesn't need to be preserved..
     - subside: Unlike all other behaviors that push using the side's presentingViewController, this behavior pushes view controllers within the side.  Use this behavior if you want to display a sub side.
     */
    open var sidePushStyle: SidePushStyle = .defaultBehavior

    /**
     The presentation mode of the side.

     There are four modes in sidePresentMode:
     - sideSlideIn: side slides in over of the existing view.
     - viewSlideOut: The existing view slides out to reveal the side.
     - viewSlideInOut: The existing view slides out while the side slides in.
     - sideDissolveIn: The side dissolves in over the existing view controller.
     */
    open var sidePresentMode: SidePresentMode = .viewSlideOut

    /// Prevents the same view controller (or a view controller of the same class) from being pushed more than once. Defaults to true.
    open var sideAllowPushOfSameClassTwice = true

    /**
     Width of the side when presented on screen, showing the existing view controller in the remaining space. Default is 75% of the screen width or 240 points, whichever is smaller.

     Note that each side's width can be overridden using the `sideWidth` property on any `UIsideNavigationController` instance.
     */
    open var sideWidth: CGFloat = appScreenRect.width


    /// Duration of the animation when the side is presented without gestures. Default is 0.35 seconds.
    open var sideAnimationPresentDuration: Double = 0.35

    /// Duration of the animation when the side is dismissed without gestures. Default is 0.35 seconds.
    open var sideAnimationDismissDuration: Double = 0.35

    /// Duration of the remaining animation when the side is partially dismissed with gestures. Default is 0.35 seconds.
    open var sideAnimationCompleteGestureDuration: Double = 0.35

    /// Amount to fade the existing view controller when the side is presented. Default is 0 for no fade. Set to 1 to fade completely.
    open var sideAnimationFadeStrength: CGFloat = 0

    /// The amount to scale the existing view controller or the side view controller depending on the `sidePresentMode`. Default is 1 for no scaling. Less than 1 will shrink, greater than 1 will grow.
    open var sideAnimationTransformScaleFactor: CGFloat = 1

    /// The background color behind side animations. Depending on the animation settings this may not be visible. If `sideFadeStatusBar` is true, this color is used to fade it. Default is black.
    open var sideAnimationBackgroundColor: UIColor?

    /// The shadow opacity around the side view controller or existing view controller depending on the `sidePresentMode`. Default is 0.5 for 50% opacity.
    open var sideShadowOpacity: Float = 0.5

    /// The shadow color around the side view controller or existing view controller depending on the `sidePresentMode`. Default is black.
    open var sideShadowColor = UIColor.black

    /// The radius of the shadow around the side view controller or existing view controller depending on the `sidePresentMode`. Default is 5.
    open var sideShadowRadius: CGFloat = 5

    /// Enable or disable interaction with the presenting view controller while the side is displayed. Enabling may make it difficult to dismiss the side or cause exceptions if the user tries to present and already presented side. Default is false.
    open var sidePresentingViewControllerUserInteractionEnabled: Bool = false

    /// The strength of the parallax effect on the existing view controller. Does not apply to `sidePresentMode` when set to `ViewSlideOut`. Default is 0.
    open var sideParallaxStrength: Int = 0

    /// Draws the `sideAnimationBackgroundColor` behind the status bar. Default is true.
    open var sideFadeStatusBar = true

    /// The animation options when a side is displayed. Ignored when displayed with a gesture.
    open var sideAnimationOptions: UIView.AnimationOptions = .curveEaseInOut

    ///    Animation curve of the remaining animation when the side is partially dismissed with gestures. Default is .easeIn.
    open var sideAnimationCompletionCurve: UIView.AnimationCurve = .easeIn

    /// The animation spring damping when a side is displayed. Ignored when displayed with a gesture.
    open var sideAnimationUsingSpringWithDamping: CGFloat = 1

    /// The animation initial spring velocity when a side is displayed. Ignored when displayed with a gesture.
    open var sideAnimationInitialSpringVelocity: CGFloat = 1

    /**
     Automatically dismisses the side when another view is pushed from it.

     Note: to prevent the side from dismissing when presenting, set modalPresentationStyle = .overFullScreen
     of the view controller being presented in storyboard or during its initalization.
     */
    open var sideDismissOnPush = true

    /// Forces sides to always animate when appearing or disappearing, regardless of a pushed view controller's animation.
    open var sideAlwaysAnimate = false

    /// Automatically dismisses the side when app goes to the background.
    open var sideDismissWhenBackgrounded = true

    /// Default instance of sideManager.
    public static let `default` = SideManager()

    /// Default instance of sideManager (objective-C).
    open class var defaultManager: SideManager {
        return SideManager.default
    }

    internal var transition: SideTransition!

    /**
     The blur effect style of the side if the side's root view controller is a UITableViewController or UICollectionViewController.

     - Note: If you want cells in a UITableViewController side to show vibrancy, make them a subclass of UITableViewVibrantCell.
     */
    open var sideBlurEffectStyle: UIBlurEffect.Style? {
        didSet {
            if oldValue != sideBlurEffectStyle {
                updatesideBlurIfNecessary()
            }
        }
    }

    /// The right side.
    open var sideRightNavigationController: UISideNavigationController? {
        willSet {
            guard sideRightNavigationController != newValue, sideRightNavigationController?.presentingViewController == nil else {
                return
            }
            removesideBlurForside(sideRightNavigationController)
        }
        didSet {
            guard sideRightNavigationController != oldValue else {
                return
            }
            guard oldValue?.presentingViewController == nil else {
                print("side Warning: sideRightNavigationController cannot be modified while it's presented.")
                sideRightNavigationController = oldValue
                return
            }
            setupNavigationController(sideRightNavigationController/*, leftSide: false*/)
        }
    }

    /// The right side swipe to dismiss gesture.
    open weak var sideRightSwipeToDismissGesture: UIPanGestureRecognizer? {
        didSet {
            oldValue?.view?.removeGestureRecognizer(oldValue!)
            setupGesture(gesture: sideRightSwipeToDismissGesture)
        }
    }

    fileprivate func setupGesture(gesture: UIPanGestureRecognizer?) {
        guard let gesture = gesture else {
            return
        }

        gesture.addTarget(transition, action:#selector(SideTransition.handleHideSidePan(_:)))
    }

    fileprivate func setupNavigationController(_ forside: UISideNavigationController?/*, leftSide: Bool*/) {
        guard let forside = forside else {
            return
        }

        forside.transitioningDelegate = transition
        forside.modalPresentationStyle = .overFullScreen

        if forside.sideManager != self {
           if forside.sideManager?.sideRightNavigationController == forside {
                print("side Warning: \(String(describing: forside.self)) was already assigned to the sideRightNavigationController of \(String(describing: forside.sideManager!.self)). When using multiple sideManagers you may want to use new instances of UIsideNavigationController instead of existing instances to avoid crashes if the side is presented more than once.")
            }
            forside.sideManager = self
        }

        forside.locked = true

        if sideEnableSwipeGestures {
            let exitPanGesture = UIPanGestureRecognizer()
            exitPanGesture.cancelsTouchesInView = false
            forside.view.addGestureRecognizer(exitPanGesture)
            sideRightSwipeToDismissGesture = exitPanGesture
        }

        // Ensures minimal lag when revealing the side for the first time using gestures by loading the view:
        let _ = forside.topViewController?.view

        updatesideBlurIfNecessary()
    }

    /// Enable or disable gestures that would swipe to dismiss the side. Default is true.
    open var sideEnableSwipeGestures: Bool = true {
        didSet {
            sideRightSwipeToDismissGesture?.view?.removeGestureRecognizer(sideRightSwipeToDismissGesture!)
            setupNavigationController(sideRightNavigationController)
        }
    }

    fileprivate func updatesideBlurIfNecessary() {
        if let sideRightNavigationController = self.sideRightNavigationController {
            setupsideBlurForside(sideRightNavigationController)
        }
    }

    fileprivate func setupsideBlurForside(_ forside: UISideNavigationController?) {
        removesideBlurForside(forside)

        guard let forside = forside,
            let sideBlurEffectStyle = sideBlurEffectStyle,
            let view = forside.topViewController?.view,
            !UIAccessibility.isReduceTransparencyEnabled else {
                return
        }

        if forside.originalBackgroundColor == nil {
            forside.originalBackgroundColor = view.backgroundColor
        }

        let blurEffect = UIBlurEffect(style: sideBlurEffectStyle)
        let blurView = UIVisualEffectView(effect: blurEffect)
        view.backgroundColor = UIColor.clear
        if let tableViewController = forside.topViewController as? UITableViewController {
            tableViewController.tableView.backgroundView = blurView
            tableViewController.tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
            tableViewController.tableView.reloadData()
        } else {
            blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            blurView.frame = view.bounds
            view.insertSubview(blurView, at: 0)
        }
    }

    fileprivate func removesideBlurForside(_ forside: UISideNavigationController?) {
        guard let forside = forside,
            let originalsideBackgroundColor = forside.originalBackgroundColor,
            let view = forside.topViewController?.view else {
                return
        }

        view.backgroundColor = originalsideBackgroundColor
        forside.originalBackgroundColor = nil

        if let tableViewController = forside.topViewController as? UITableViewController {
            tableViewController.tableView.backgroundView = nil
            tableViewController.tableView.separatorEffect = nil
            tableViewController.tableView.reloadData()
        } else if let blurView = view.subviews[0] as? UIVisualEffectView {
            blurView.removeFromSuperview()
        }
    }

    /**
     Adds screen edge gestures to a view to present a side.

     - Parameter toView: The view to add gestures to.
     - Parameter forside: The side (left or right) you want to add a gesture for. If unspecified, gestures will be added for both sides.

     - Returns: The array of screen edge gestures added to `toView`.
     */
//    @discardableResult open func sideAddScreenEdgePanGesturesToPresent(toView: UIView, forside:UIRectEdge? = nil) -> [UIScreenEdgePanGestureRecognizer] {
    @discardableResult open func sideAddScreenEdgePanGesturesToPresent(toView: UIView) -> [UIScreenEdgePanGestureRecognizer] {
    var array = [UIScreenEdgePanGestureRecognizer]()

        let newScreenEdgeGesture = { () -> UIScreenEdgePanGestureRecognizer in
            let screenEdgeGestureRecognizer = UIScreenEdgePanGestureRecognizer()
            screenEdgeGestureRecognizer.cancelsTouchesInView = true
            toView.addGestureRecognizer(screenEdgeGestureRecognizer)
            array.append(screenEdgeGestureRecognizer)
            return screenEdgeGestureRecognizer
        }

        let rightScreenEdgeGestureRecognizer = newScreenEdgeGesture()
        rightScreenEdgeGestureRecognizer.addTarget(transition, action:#selector(SideTransition.handlePresentsideRightScreenEdge(_:)))
        rightScreenEdgeGestureRecognizer.edges = .right

        if sideRightNavigationController == nil {
            print("side Warning: sideAddScreenEdgePanGesturesToPresent was called before sideRightNavigationController was set. The gesture will not work without a side. Use sideAddScreenEdgePanGesturesToPresent(toView:forside:) to add gestures for only one side.")
        }
        return array
    }
}

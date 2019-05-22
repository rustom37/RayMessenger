//
//  UISideNavigationController.swift
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

@objc public protocol UISideNavigationControllerDelegate {
    @objc optional func sideWillAppear(side: UISideNavigationController, animated: Bool)
    @objc optional func sideDidAppear(side: UISideNavigationController, animated: Bool)
    @objc optional func sideWillDisappear(side: UISideNavigationController, animated: Bool)
    @objc optional func sideDidDisappear(side: UISideNavigationController, animated: Bool)
}

@objcMembers
open class UISideNavigationController: UINavigationController {

    fileprivate weak var foundDelegate: UISideNavigationControllerDelegate?
    fileprivate weak var activeDelegate: UISideNavigationControllerDelegate? {
        guard !view.isHidden else {
            return nil
        }

        return sideDelegate ?? foundDelegate ?? findDelegate(forViewController: presentingViewController)
    }
    fileprivate func findDelegate(forViewController: UIViewController?) -> UISideNavigationControllerDelegate? {
        if let navigationController = forViewController as? UINavigationController {
            return findDelegate(forViewController: navigationController.topViewController)
        }
        if let tabBarController = forViewController as? UITabBarController {
            return findDelegate(forViewController: tabBarController.selectedViewController)
        }
        if let splitViewController = forViewController as? UISplitViewController {
            return findDelegate(forViewController: splitViewController.viewControllers.last)
        }

        foundDelegate = forViewController as? UISideNavigationControllerDelegate
        return foundDelegate
    }
    fileprivate var usingInterfaceBuilder = false
    internal var locked = false
    internal var originalBackgroundColor: UIColor?
    internal var transition: SideTransition {
        return sideManager.transition
    }

    /// Delegate for receiving appear and disappear related events. If `nil` the visible view controller that displays a `UISideNavigationController` automatically receives these events.
    open weak var sideDelegate: UISideNavigationControllerDelegate?

    /// SideManager instance associated with this . Default is `SideManager.default`. This property cannot be changed after the  has loaded.
    open weak var sideManager: SideManager! = SideManager.default {
        didSet {
            if locked && oldValue != nil {
                print("Side Warning: a 's sideManager property cannot be changed after it has loaded.")
                sideManager = oldValue
            }
        }
    }

    /// Width of the  when presented on screen, showing the existing view controller in the remaining space. Default is zero. When zero, `sideManager.Width` is used. This property cannot be changed while the isHidden property is false.
    @IBInspectable open var sideWidth: CGFloat = 0 {
        didSet {
            if !isHidden && oldValue != sideWidth {
                print("Side Warning: a 's width property can only be changed when it is hidden.")
                sideWidth = oldValue
            }
        }
    }

    /// Whether the  appears on the right or left side of the screen. Right is the default. This property cannot be changed after the  has loaded.
    @IBInspectable open var leftSide: Bool = false {
        didSet {
            if locked && leftSide != oldValue {
                print("Side Warning: a 's leftSide property cannot be changed after it has loaded.")
                leftSide = oldValue
            }
        }
    }

    /// Indicates if the  is anywhere in the view hierarchy, even if covered by another view controller.
    open var isHidden: Bool {
        return presentingViewController == nil
    }

    #if !STFU_SIDE
    // This override prevents newbie developers from creating black/blank s and opening newbie issues.
    // If you would like to remove this override, define STFU_SIDE in the Active Compilation Conditions of your .plist file.
    // Sorry for the inconvenience experienced developers :(
    @available(*, unavailable, renamed: "init(rootViewController:)")
    public init() {
        fatalError("init is not available")
    }

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    #endif

    open override func awakeFromNib() {
        super.awakeFromNib()

        usingInterfaceBuilder = true
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        if !locked && usingInterfaceBuilder {
            if leftSide {
                sideManager.sideLeftNavigationController = self
            } else {
                sideManager.sideRightNavigationController = self
            }
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Dismiss keyboard to prevent weird keyboard animations from occurring during transition
        presentingViewController?.view.endEditing(true)

        foundDelegate = nil
        activeDelegate?.sideWillAppear?(side: self, animated: animated)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // We had presented a view before, so lets dismiss ourselves as already acted upon
        if view.isHidden {
            transition.hideSideComplete()
            dismiss(animated: false, completion: { () -> Void in
                self.view.isHidden = false
            })

            return
        }

        activeDelegate?.sideDidAppear?(side: self, animated: animated)

        #if !STFU_SIDE
        if topViewController == nil {
            print("Side Warning: the  doesn't have a view controller to show! UISideNavigationController needs a view controller to display just like a UINavigationController.")
        }
        #endif
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // When presenting a view controller from the , the  view gets moved into another transition view above our transition container
        // which can break the visual layout we had before. So, we move the  view back to its original transition view to preserve it.
        if !isBeingDismissed {
            guard let sideManager = sideManager else {
                return
            }

            if let mainView = transition.mainViewController?.view {
                switch sideManager.sidePresentMode {
                case .viewSlideOut, .viewSlideInOut:
                    mainView.superview?.insertSubview(view, belowSubview: mainView)
                case .sideSlideIn, .sideDissolveIn:
                    if let tapView = transition.tapView {
                        mainView.superview?.insertSubview(view, aboveSubview: tapView)
                    } else {
                        mainView.superview?.insertSubview(view, aboveSubview: mainView)
                    }
                }
            }

            // We're presenting a view controller from the , so we need to hide the  so it isn't showing when the presented view is dismissed.
            UIView.animate(withDuration: animated ? sideManager.sideAnimationDismissDuration : 0,
                           delay: 0,
                           usingSpringWithDamping: sideManager.sideAnimationUsingSpringWithDamping,
                           initialSpringVelocity: sideManager.sideAnimationInitialSpringVelocity,
                           options: sideManager.sideAnimationOptions,
                           animations: {
                            self.transition.hideSideStart()
                            self.activeDelegate?.sideWillDisappear?(side: self, animated: animated)
            }) { (finished) -> Void in
                self.activeDelegate?.sideDidDisappear?(side: self, animated: animated)
                self.view.isHidden = true
            }

            return
        }

        activeDelegate?.sideWillDisappear?(side: self, animated: animated)
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Work-around: if the  is dismissed without animation the transition logic is never called to restore the
        // the view hierarchy leaving the screen black/empty. This is because the transition moves views within a container
        // view, but dismissing without animation removes the container view before the original hierarchy is restored.
        // This check corrects that.
        if let sideDelegate = activeDelegate as? UIViewController, sideDelegate.view.window == nil {
            transition.hideSideStart().hideSideComplete()
        }

        activeDelegate?.sideDidDisappear?(side: self, animated: animated)

        // Clear selecton on UITableViewControllers when reappearing using custom transitions
        guard let tableViewController = topViewController as? UITableViewController,
            let tableView = tableViewController.tableView,
            let indexPaths = tableView.indexPathsForSelectedRows,
            tableViewController.clearsSelectionOnViewWillAppear else {
                return
        }

        for indexPath in indexPaths {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Don't bother resizing if the view isn't visible
        guard !view.isHidden else {
            return
        }

        NotificationCenter.default.removeObserver(self.transition, name: UIApplication.willChangeStatusBarFrameNotification, object: nil)
        coordinator.animate(alongsideTransition: { (context) in
            self.transition.presentsideStart()
        }) { (context) in
            NotificationCenter.default.addObserver(self.transition, selector:#selector(SideTransition.handleNotification), name: UIApplication.willChangeStatusBarFrameNotification, object: nil)
        }
    }

    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        guard let sideManager = sideManager, viewControllers.count > 0 && sideManager.sidePushStyle != .subside else {
            // NOTE: pushViewController is called by init(rootViewController: UIViewController)
            // so we must perform the normal super method in this case.
            super.pushViewController(viewController, animated: animated)
            return
        }

        let splitViewController = presentingViewController as? UISplitViewController
        let tabBarController = presentingViewController as? UITabBarController
        let potentialNavigationController = (splitViewController?.viewControllers.first ?? tabBarController?.selectedViewController) ?? presentingViewController
        guard let navigationController = potentialNavigationController as? UINavigationController else {
            print("Side Warning: attempt to push a View Controller from \(String(describing: potentialNavigationController.self)) where its navigationController == nil. It must be embedded in a Navigation Controller for this to work.")
            return
        }

        let activeDelegate = self.activeDelegate
        foundDelegate = nil

        // To avoid overlapping dismiss & pop/push calls, create a transaction block where the
        // is dismissed after showing the appropriate screen
        CATransaction.begin()
        if sideManager.sideDismissOnPush {
            let animated = animated || sideManager.sideAlwaysAnimate

            CATransaction.setCompletionBlock( { () -> Void in
                activeDelegate?.sideDidDisappear?(side: self, animated: animated)
                if !animated {
                    self.transition.hideSideStart().hideSideComplete()
                }
                self.dismiss(animated: animated, completion: nil)
            })

            if animated {
                let areAnimationsEnabled = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(true)
                UIView.animate(withDuration: sideManager.sideAnimationDismissDuration,
                               delay: 0,
                               usingSpringWithDamping: sideManager.sideAnimationUsingSpringWithDamping,
                               initialSpringVelocity: sideManager.sideAnimationInitialSpringVelocity,
                               options: sideManager.sideAnimationOptions,
                               animations: {
                                activeDelegate?.sideWillDisappear?(side: self, animated: animated)
                                self.transition.hideSideStart()
                })
                UIView.setAnimationsEnabled(areAnimationsEnabled)
            }
        }

        if let lastViewController = navigationController.viewControllers.last, !sideManager.sideAllowPushOfSameClassTwice && type(of: lastViewController) == type(of: viewController) {
            CATransaction.commit()
            return
        }

        switch sideManager.sidePushStyle {
        case .subside, .defaultBehavior: break // .sub handled earlier, .defaultBehavior falls through to end
        case .popWhenPossible:
            for subViewController in navigationController.viewControllers.reversed() {
                if type(of: subViewController) == type(of: viewController) {
                    navigationController.popToViewController(subViewController, animated: animated)
                    CATransaction.commit()
                    return
                }
            }
        case .preserve, .preserveAndHideBackButton:
            var viewControllers = navigationController.viewControllers
            let filtered = viewControllers.filter { preservedViewController in type(of: preservedViewController) == type(of: viewController) }
            if let preservedViewController = filtered.last {
                viewControllers = viewControllers.filter { subViewController in subViewController !== preservedViewController }
                if sideManager.sidePushStyle == .preserveAndHideBackButton {
                    preservedViewController.navigationItem.hidesBackButton = true
                }
                viewControllers.append(preservedViewController)
                navigationController.setViewControllers(viewControllers, animated: animated)
                CATransaction.commit()
                return
            }
            if sideManager.sidePushStyle == .preserveAndHideBackButton {
                viewController.navigationItem.hidesBackButton = true
            }
        case .replace:
            viewController.navigationItem.hidesBackButton = true
            navigationController.setViewControllers([viewController], animated: animated)
            CATransaction.commit()
            return
        }

        navigationController.pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }


}

//
//  ChatCell.swift
//  RayMessenger
//
//  Created by Steve Rustom on 5/15/19.
//  Copyright © 2019 Steve Rustom. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet var bubbleImage: UIImageView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timeSent: UILabel!

    fileprivate var outgoingLeading: NSLayoutConstraint?
    fileprivate var outgoingTrailing: NSLayoutConstraint?

    fileprivate var incomingLeading: NSLayoutConstraint?
    fileprivate var incomingTrailing: NSLayoutConstraint?
//    let storyboard = UIStoryboard(name: "Main", bundle: nil)

    override func awakeFromNib() {
        super.awakeFromNib()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(selectAllOfLabel))
        message.isUserInteractionEnabled = true
        message.addGestureRecognizer(longPress)

//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
//        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
//        self.addGestureRecognizer(swipeLeft)


        configureCell()
    }

//    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            switch swipeGesture.direction {
//            case .right:
//                break
//            case .left:
//                guard let newViewController = (storyboard.instantiateViewController(withIdentifier: "timeInfoViewController") as? TimeInfoViewController) else { return }
//                let nav = UINavigationController(rootViewController: newViewController)
//                self.window?.rootViewController = nav
//            default:
//                break
//            }
//        }
//
//    }

    // MARK: - Cell Configuration
    fileprivate func configureCell() {
        message.numberOfLines = 0
        message.font = UIFont.systemFont(ofSize: 18)
        message.textColor = .white

        timeSent.numberOfLines = 0
        timeSent.font = UIFont.systemFont(ofSize: 10)
        timeSent.textColor = .white

        bubbleImage.translatesAutoresizingMaskIntoConstraints = false
        bubbleImage.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 15).isActive = true
        bubbleImage.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -15).isActive = true

        message.translatesAutoresizingMaskIntoConstraints = false
        message.topAnchor.constraint(equalTo: bubbleImage.topAnchor, constant: 7).isActive = true
        message.bottomAnchor.constraint(equalTo: bubbleImage.bottomAnchor, constant: -7).isActive = true
        message.leadingAnchor.constraint(equalTo: bubbleImage.leadingAnchor, constant: 15).isActive = true
        message.trailingAnchor.constraint(equalTo: bubbleImage.trailingAnchor, constant: -45).isActive = true

        timeSent.translatesAutoresizingMaskIntoConstraints = false
        timeSent.topAnchor.constraint(equalTo: bubbleImage.topAnchor, constant: 30).isActive = true
        timeSent.bottomAnchor.constraint(equalTo: bubbleImage.bottomAnchor, constant: -5).isActive = true
         timeSent.leadingAnchor.constraint(equalTo: message.trailingAnchor, constant: 5).isActive = true
        timeSent.trailingAnchor.constraint(equalTo: bubbleImage.trailingAnchor, constant: -5).isActive = true



        outgoingLeading = bubbleImage.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.leadingAnchor, constant: 20)
        outgoingTrailing = bubbleImage.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20)

        incomingLeading = bubbleImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20)
        incomingTrailing = bubbleImage.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: 20)
    }

    func showOutgoingMessage(color: UIColor, text: String, time: String) {
        message.text = text
        timeSent.text = time
        let bubbleImg = UIImage(named: "outgoing-message-bubble")?.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch).withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        bubbleImage.image = bubbleImg
        bubbleImage.tintColor = color

        outgoingTrailing?.isActive = true
        outgoingLeading?.isActive = true
        incomingTrailing?.isActive = false
        incomingLeading?.isActive = false
    }

    func showIncomingMessage(color: UIColor, text: String, time: String) {
        message.text = text
        timeSent.text = time
        let bubbleImg = UIImage(named: "incoming-message-bubble")?.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch).withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        bubbleImage.image = bubbleImg
        bubbleImage.tintColor = color

        outgoingTrailing?.isActive = false
        outgoingLeading?.isActive = false
        incomingTrailing?.isActive = true
        incomingLeading?.isActive = true
    }

    // MARK: - UILabel Add-ons
    @objc func selectAllOfLabel(recognizer: UIGestureRecognizer) {
        let loc = recognizer.location(in: self.message)
        self.message.showMenu(location: loc)
    }

//    fileprivate func setupSide() {
//        // Define the menus
//        SideManager.default.sideRightNavigationController = storyboard!.instantiateViewController(withIdentifier: "RightNavigationController") as? UISideNavigationController
//
//        // Enable gestures. The left and/or right menus must be set up above for these to work.
//        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
//        SideManager.default.sideAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
//        //        SideManager.default.sideAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
//        SideManager.default.sideAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view, forside: UIRectEdge.right)
//
//        // Set up a cool background image for demo purposes
//        SideManager.default.sideAnimationBackgroundColor = UIColor.white
//    }

//    // MARK: - Vibrant Cel
//    fileprivate var vibrancyView:UIVisualEffectView = UIVisualEffectView()
//    fileprivate var vibrancySelectedBackgroundView:UIVisualEffectView = UIVisualEffectView()
//    fileprivate var defaultSelectedBackgroundView:UIView?
//    open var blurEffectStyle: UIBlurEffect.Style? {
//        didSet {
//            updateBlur()
//        }
//    }
//
//    // For registering with UITableView without subclassing otherwise dequeuing instance of the cell causes an exception
//    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//
//    required public init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
//        vibrancyView.frame = bounds
//        vibrancyView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        for view in subviews {
//            vibrancyView.contentView.addSubview(view)
//        }
//        addSubview(vibrancyView)
//
//        let blurSelectionEffect = UIBlurEffect(style: .light)
//        vibrancySelectedBackgroundView.effect = blurSelectionEffect
//        defaultSelectedBackgroundView = selectedBackgroundView
//
//        updateBlur()
//    }
//
//    internal func updateBlur() {
//        // shouldn't be needed but backgroundColor is set to white on iPad:
//        backgroundColor = UIColor.clear
//
//        if let blurEffectStyle = blurEffectStyle, !UIAccessibility.isReduceTransparencyEnabled {
//            let blurEffect = UIBlurEffect(style: blurEffectStyle)
//            vibrancyView.effect = UIVibrancyEffect(blurEffect: blurEffect)
//
//            if selectedBackgroundView != nil && selectedBackgroundView != vibrancySelectedBackgroundView {
//                vibrancySelectedBackgroundView.contentView.addSubview(selectedBackgroundView!)
//                selectedBackgroundView = vibrancySelectedBackgroundView
//            }
//        } else {
//            vibrancyView.effect = nil
//            selectedBackgroundView = defaultSelectedBackgroundView
//        }
//    }

}

// MARK: - UILabel Extension
extension UILabel {
    override open var canBecomeFirstResponder: Bool {
        return true
    }

    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copyAll) {
            return true
        }
        return false
    }

    func showMenu(location: CGPoint) {
        self.becomeFirstResponder()
        let menuController = UIMenuController.shared
        let copyItem = UIMenuItem(title: "Copy", action: #selector(UILabel.copyAll(_:)))
        menuController.menuItems = [copyItem]
        let rect = CGRect(x: location.x - 35, y: self.frame.origin.y, width: 50, height: self.frame.height)
        menuController.setTargetRect(rect, in: self)
        menuController.setMenuVisible(true, animated: true)
    }

    @objc func copyAll(_ sender: Any?) {
        UIPasteboard.general.string = self.text
    }
}

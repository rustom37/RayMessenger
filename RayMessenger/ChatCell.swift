//
//  ChatCell.swift
//  RayMessenger
//
//  Created by Steve Rustom on 5/15/19.
//  Copyright © 2019 Steve Rustom. All rights reserved.
//

import UIKit

//protocol ChatCellDelegate {
//    func hasPerformedSwipe(touch: CGPoint)
//}

class ChatCell: UITableViewCell {

    @IBOutlet var bubbleImage: UIImageView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timeSent: UILabel!

    fileprivate var outgoingLeading: NSLayoutConstraint?
    fileprivate var outgoingTrailing: NSLayoutConstraint?

    fileprivate var incomingLeading: NSLayoutConstraint?
    fileprivate var incomingTrailing: NSLayoutConstraint?

//    fileprivate var vibrancyView:UIVisualEffectView = UIVisualEffectView()
//    fileprivate var vibrancySelectedBackgroundView:UIVisualEffectView = UIVisualEffectView()
//    fileprivate var defaultSelectedBackgroundView:UIView?

//    var delegate: ChatCellDelegate?
//    var originalCenter = CGPoint()
//    var isSwipeSuccessful = false
//    var touch = CGPoint()

    override func awakeFromNib() {
        super.awakeFromNib()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(selectAllOfLabel))
        message.isUserInteractionEnabled = true
        message.addGestureRecognizer(longPress)

//        let pRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
//        pRecognizer.delegate = self
//        addGestureRecognizer(pRecognizer)

        configureCell()
    }

//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
//            let translation = panGestureRecognizer.translation(in: superview!)
//            if (abs(translation.x) > abs(translation.y)) && (translation.x < 0){
//                touch = panGestureRecognizer.location(in: superview)
//                return true
//            }
//            return false
//        }else if gestureRecognizer is UITapGestureRecognizer {
//            touch = gestureRecognizer.location(in: superview)
//            return true
//        }
//        return false
//    }
//
//    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
//        if recognizer.state == .began {
//            originalCenter = center
//        }
//
//        if recognizer.state == .changed {
//            checkIfSwiped(recognizer: recognizer)
//            delegate?.hasPerformedSwipe(touch: touch)
//        }
//
//        if recognizer.state == .ended {
//            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
//            if isSwipeSuccessful{
////                delegate?.hasPerformedSwipe(touch: touch)
//                moveViewBackIntoPlaceSlowly(originalFrame: originalFrame)
//            } else {
//                moveViewBackIntoPlace(originalFrame: originalFrame)
//            }
//        }
//    }
//
//    func checkIfSwiped(recognizer: UIPanGestureRecognizer) {
//        let translation = recognizer.translation(in: self)
//        center = CGPoint(x: originalCenter.x + max(translation.x, -20), y: originalCenter.y)
//        isSwipeSuccessful = frame.origin.x < -frame.size.width / 3.0
//    }
//
//    private func moveViewBackIntoPlace(originalFrame: CGRect) {
//        UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
//    }
//
//    private func moveViewBackIntoPlaceSlowly(originalFrame: CGRect) {
//        UIView.animate(withDuration: 1.5, animations: {self.frame = originalFrame})
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

//    // MARK: - Vibrance Effects
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

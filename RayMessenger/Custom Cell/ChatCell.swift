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

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }

    // MARK: - Cell Configuration
    func configureCell() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(selectAllOfLabel))
        message.isUserInteractionEnabled = true
        message.addGestureRecognizer(longPress)

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

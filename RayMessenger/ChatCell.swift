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

    fileprivate var outgoingLeading: NSLayoutConstraint?
    fileprivate var outgoingTrailing: NSLayoutConstraint?

    fileprivate var incomingLeading: NSLayoutConstraint?
    fileprivate var incomingTrailing: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }

    fileprivate func configureCell() {
        message.numberOfLines = 0
        message.font = UIFont.systemFont(ofSize: 18)
        message.textColor = .white

        bubbleImage.translatesAutoresizingMaskIntoConstraints = false
        bubbleImage.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 15).isActive = true
        bubbleImage.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -15).isActive = true

        message.translatesAutoresizingMaskIntoConstraints = false
        message.topAnchor.constraint(equalTo: bubbleImage.topAnchor, constant: 7).isActive = true
        message.bottomAnchor.constraint(equalTo: bubbleImage.bottomAnchor, constant: -7).isActive = true
        message.leadingAnchor.constraint(equalTo: bubbleImage.leadingAnchor, constant: 20).isActive = true
        message.trailingAnchor.constraint(equalTo: bubbleImage.trailingAnchor, constant: -20).isActive = true


        outgoingLeading = bubbleImage.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.leadingAnchor, constant: 20)
        outgoingTrailing = bubbleImage.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20)

        incomingLeading = bubbleImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20)
        incomingTrailing = bubbleImage.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: 20)
    }

    func showOutgoingMessage(color: UIColor, text: String) {
        message.text = text
        let bubbleImg = UIImage(named: "outgoing-message-bubble")?.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch).withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        bubbleImage.image = bubbleImg
        bubbleImage.tintColor = color

        outgoingTrailing?.isActive = true
        outgoingLeading?.isActive = true
        incomingTrailing?.isActive = false
        incomingLeading?.isActive = false
    }

    func showIncomingMessage(color: UIColor, text: String) {
        message.text = text
        let bubbleImg = UIImage(named: "incoming-message-bubble")?.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch).withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        bubbleImage.image = bubbleImg
        bubbleImage.tintColor = color

        outgoingTrailing?.isActive = false
        outgoingLeading?.isActive = false
        incomingTrailing?.isActive = true
        incomingLeading?.isActive = true
    }
}

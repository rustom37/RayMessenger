//
//  ChatCell.swift
//  RayMessenger
//
//  Created by Steve Rustom on 5/15/19.
//  Copyright © 2019 Steve Rustom. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureCell(sent: Bool, string: String) {
        if sent == true {
            showOutgoingMessage(color: UIColor.red, text: string)
        } else {
            showIncomingMessage(color: UIColor.green, text: string)
        }
    }

    private func showOutgoingMessage(color: UIColor, text: String) {
        let label =  UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.text = text

        let constraintRect = CGSize(width: 0.66 * self.contentView.frame.width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: label.font], context: nil)
        label.frame.size = CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))

        let bubbleImageSize = CGSize(width: (label.frame.width) + 28, height: (label.frame.height) + 20)

        let outgoingMessageView = UIImageView(frame: CGRect(x: self.contentView.frame.width - bubbleImageSize.width - 20, y: self.contentView.frame.height - bubbleImageSize.height - 10, width: bubbleImageSize.width, height: bubbleImageSize.height))

        let bubbleImage = UIImage(named: "outgoing-message-bubble")?.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch).withRenderingMode(UIImage.RenderingMode.alwaysTemplate)

        outgoingMessageView.image = bubbleImage
        outgoingMessageView.tintColor = color

        self.contentView.addSubview(outgoingMessageView)
        outgoingMessageView.translatesAutoresizingMaskIntoConstraints = false
        print(self.contentView.frame.height - outgoingMessageView.frame.height)
        outgoingMessageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: (self.contentView.frame.height - outgoingMessageView.frame.height)/2).isActive = true
        outgoingMessageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -(self.contentView.frame.height - outgoingMessageView.frame.height)/2).isActive = true
        outgoingMessageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: (self.contentView.frame.width - outgoingMessageView.frame.width)-20).isActive = true
        outgoingMessageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true


        label.center = outgoingMessageView.center
        self.contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: outgoingMessageView.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: outgoingMessageView.bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: outgoingMessageView.leadingAnchor, constant: 10).isActive = true
        label.trailingAnchor.constraint(equalTo: outgoingMessageView.trailingAnchor, constant: 20).isActive = true
    }

    private func showIncomingMessage(color: UIColor, text: String) {
        let label =  UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.text = text

        let constraintRect = CGSize(width: 0.66 * self.contentView.frame.width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: label.font], context: nil)
        label.frame.size = CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
        let bubbleImageSize = CGSize(width: (label.frame.width) + 28, height: (label.frame.height) + 20)

        let incomingMessageView = UIImageView(frame: CGRect(x: 0, y: self.contentView.frame.height - bubbleImageSize.height - 20, width: bubbleImageSize.width, height: bubbleImageSize.height))

        let bubbleImage = UIImage(named: "incoming-message-bubble")?.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21))

        incomingMessageView.image = bubbleImage
        incomingMessageView.tintColor = color

        self.contentView.addSubview(incomingMessageView)
        incomingMessageView.translatesAutoresizingMaskIntoConstraints = false
         print(self.contentView.frame.height - incomingMessageView.frame.height)
        incomingMessageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: (self.contentView.frame.height - incomingMessageView.frame.height)/2).isActive = true
        incomingMessageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -(self.contentView.frame.height - incomingMessageView.frame.height)/2).isActive = true
        incomingMessageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        incomingMessageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -(self.contentView.frame.width - incomingMessageView.frame.width)+20).isActive = true

        label.center = incomingMessageView.center
        self.contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: incomingMessageView.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: incomingMessageView.bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: incomingMessageView.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: incomingMessageView.trailingAnchor, constant: 10).isActive = true
    }
}

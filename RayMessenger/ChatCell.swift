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

    func showOutgoingMessage(color: UIColor, text: String) {
        let label =  UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.text = text

        print("FRAME minx: \(self.contentView.frame.minX), miny \(self.contentView.frame.minY), width: \(self.contentView.frame.width), height: \(self.contentView.frame.height)")

        let constraintRect = CGSize(width: 0.66 * self.contentView.frame.width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: label.font], context: nil)
        label.frame.size = CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))

        let bubbleImageSize = CGSize(width: (label.frame.width) + 28, height: (label.frame.height) + 20)

        let outgoingMessageView = UIImageView(frame: CGRect(x: self.contentView.frame.width - bubbleImageSize.width - 20, y: self.contentView.frame.height - bubbleImageSize.height - 10, width: bubbleImageSize.width, height: bubbleImageSize.height))

        let bubbleImage = UIImage(named: "outgoing-message-bubble")?.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch).withRenderingMode(UIImage.RenderingMode.alwaysTemplate)

        print("View minx: \(outgoingMessageView.frame.minX), miny \(outgoingMessageView.frame.minY), width: \(outgoingMessageView.frame.width), height: \(outgoingMessageView.frame.height)")

        outgoingMessageView.image = bubbleImage
        outgoingMessageView.tintColor = color

        self.contentView.addSubview(outgoingMessageView)
        label.center = outgoingMessageView.center
        self.contentView.addSubview(label)
    }

    func showIncomingMessage(color: UIColor, text: String) {
        let label =  UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.text = text

        let constraintRect = CGSize(width: 0.66 * self.contentView.frame.width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: label.font], context: nil)
        label.frame.size = CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
        let bubbleImageSize = CGSize(width: (label.frame.width) + 28, height: (label.frame.height) + 20)

        let incomingMessageView = UIImageView(frame: CGRect(x: 20, y: self.contentView.frame.height - bubbleImageSize.height - 10, width: bubbleImageSize.width, height: bubbleImageSize.height))

        let bubbleImage = UIImage(named: "incoming-message-bubble")?.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21))

        incomingMessageView.image = bubbleImage
        incomingMessageView.tintColor = color

        self.contentView.addSubview(incomingMessageView)
        label.center = incomingMessageView.center
        self.contentView.addSubview(label)
    }
}

//
//  KeyboardNSLayoutConstraint.swift
//  RayMessenger
//
//  Created by Steve Rustom on 5/27/19.
//  Copyright © 2019 Steve Rustom. All rights reserved.
//

import UIKit

public class KeyboardNSLayoutConstraint: NSLayoutConstraint {

    private var offset : CGFloat = 0
    private var keyboardVisibleHeight : CGFloat = 0

    override public func awakeFromNib() {
        super.awakeFromNib()

        offset = constant

        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardNSLayoutConstraint.keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardNSLayoutConstraint.keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShowNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let frame = frameValue.cgRectValue
                keyboardVisibleHeight = frame.size.height
                //If device is an iPhone X, it changes the layout constraint to accomodate for the bottom bar
                if (UIDevice.current.model == "iPhone10,3") || (UIDevice.current.model == "iPhone10,6") {
                    keyboardVisibleHeight = keyboardVisibleHeight - 34
                }
            }

            self.updateConstant()
            switch (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) {
            case let (.some(duration), .some(curve)):

                let options = UIView.AnimationOptions(rawValue: curve.uintValue)

                UIView.animate(withDuration: TimeInterval(duration.doubleValue), delay: 0, options: options, animations: {                            UIApplication.shared.keyWindow?.layoutIfNeeded()
                    return
                }, completion: { finished in })
            default:

                break
            }

        }

    }

    @objc func keyboardWillHideNotification(_ notification: NSNotification) {
        keyboardVisibleHeight = 0
        self.updateConstant()

        if let userInfo = notification.userInfo {

            switch (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) {
            case let (.some(duration), .some(curve)):

                let options = UIView.AnimationOptions(rawValue: curve.uintValue)

                UIView.animate(withDuration: TimeInterval(duration.doubleValue), delay: 0, options: options, animations: {
                    UIApplication.shared.keyWindow?.layoutIfNeeded()
                    return
                }, completion: { finished in })
            default: break
            }
        }
    }

    func updateConstant() {
        self.constant = offset + keyboardVisibleHeight
    }

}

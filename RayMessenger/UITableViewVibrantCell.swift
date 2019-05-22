//
//  UITableViewVibrantCell.swift
//  RayMessenger
//
//  Created by Steve Rustom on 5/22/19.
//  Copyright © 2019 Steve Rustom. All rights reserved.
//

import UIKit

open class UITableViewVibrantCell: UITableViewCell {

    fileprivate var vibrancyView:UIVisualEffectView = UIVisualEffectView()
    fileprivate var vibrancySelectedBackgroundView:UIVisualEffectView = UIVisualEffectView()
    fileprivate var defaultSelectedBackgroundView:UIView?
    open var blurEffectStyle: UIBlurEffect.Style? {
        didSet {
            updateBlur()
        }
    }

    // For registering with UITableView without subclassing otherwise dequeuing instance of the cell causes an exception
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        vibrancyView.frame = bounds
        vibrancyView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        for view in subviews {
            vibrancyView.contentView.addSubview(view)
        }
        addSubview(vibrancyView)

        let blurSelectionEffect = UIBlurEffect(style: .light)
        vibrancySelectedBackgroundView.effect = blurSelectionEffect
        defaultSelectedBackgroundView = selectedBackgroundView

        updateBlur()
    }

    internal func updateBlur() {
        // shouldn't be needed but backgroundColor is set to white on iPad:
        backgroundColor = UIColor.clear

        if let blurEffectStyle = blurEffectStyle, !UIAccessibility.isReduceTransparencyEnabled {
            let blurEffect = UIBlurEffect(style: blurEffectStyle)
            vibrancyView.effect = UIVibrancyEffect(blurEffect: blurEffect)

            if selectedBackgroundView != nil && selectedBackgroundView != vibrancySelectedBackgroundView {
                vibrancySelectedBackgroundView.contentView.addSubview(selectedBackgroundView!)
                selectedBackgroundView = vibrancySelectedBackgroundView
            }
        } else {
            vibrancyView.effect = nil
            selectedBackgroundView = defaultSelectedBackgroundView
        }
    }
}

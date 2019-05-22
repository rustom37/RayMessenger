//
//  SideTableViewController.swift
//  RayMessenger
//
//  Created by Steve Rustom on 5/22/19.
//  Copyright © 2019 Steve Rustom. All rights reserved.
//

import UIKit

class SideTableViewController: UITableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // refresh cell blur effect in case it changed
        tableView.reloadData()

        guard SideManager.default.sideBlurEffectStyle == nil else {
            return
        }

        // Set up a cool background image for demo purposes
//        let imageView = UIImageView(image: UIImage(named: "saturn"))
//        imageView.contentMode = .scaleAspectFit
//        imageView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
//        tableView.backgroundView = imageView
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! UITableViewVibrantCell

        cell.blurEffectStyle = SideManager.default.sideBlurEffectStyle

        return cell
    }


}

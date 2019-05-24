//
//  SideTableViewController.swift
//  RayMessenger
//
//  Created by Steve Rustom on 5/22/19.
//  Copyright © 2019 Steve Rustom. All rights reserved.
//

//import UIKit
//
//class SideTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//
//    var receivedCell : ChatCell?
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // refresh cell blur effect in case it changed
//        tableView.reloadData()
//
//        guard SideManager.default.sideBlurEffectStyle == nil else {
//            return
//        }
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! UITableViewVibrantCell
//
//        cell.blurEffectStyle = SideManager.default.sideBlurEffectStyle
//
//        return cell
//    }
//}

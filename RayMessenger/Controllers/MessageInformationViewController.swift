//
//  MessageInformationViewController.swift
//  RayMessenger
//
//  Created by Steve Rustom on 5/22/19.
//  Copyright © 2019 Steve Rustom. All rights reserved.
//

import UIKit

class MessageInformationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sent: UILabel!
    @IBOutlet weak var read: UILabel!

    var receivedCell : ChatCell?
    let sideManager = SideManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "chatCell")

        configureTableView()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = receivedCell {
//            cell.blurEffectStyle =  sideManager.sideBlurEffectStyle
            cell.showOutgoingMessage(color: UIColor.purple, text: (receivedCell?.message.text)!, time: (receivedCell?.timeSent.text)!)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatCell
            return cell
        }
    }

    func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
    }
}

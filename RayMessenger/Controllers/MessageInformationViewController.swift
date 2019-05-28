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

    var messageReceived: Message?
    var date = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "chatCell")
        tableView.reloadData()

        if let message = messageReceived {
            date = "\(Calendar.current.component(.hour, from: message.timeSent)):\(Calendar.current.component(.minute, from: message.timeSent))"
            sent.text = "Sent on \(date)"
            read.text = "Read on \(date)"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatCell
        if let message = messageReceived {
            cell.showOutgoingMessage(color: UIColor.purple, text: message.string, time: date)
        }
        return cell
    }
}

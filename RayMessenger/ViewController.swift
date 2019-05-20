//
//  ViewController.swift
//  RayMessenger
//
//  Created by Steve Rustom on 5/15/19.
//  Copyright © 2019 Steve Rustom. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var entryView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    var messages: [Message] = [Message(string: "Hello, How are you?", sent: false), Message(string: "I'm fine.", sent: true), Message(string: "What did you do today?", sent: false), Message(string: "I went to the Grocery store and bought some potato chips", sent: true), Message(string: "Did you buy me some too? 🥔", sent: false)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "chatCell")

        configureTableView()
        scrollToBottomOfChat()
        tableView.reloadData()
    }

    @IBAction func send(_ sender: Any) {
        if let text = textField.text {
            if text.count > 0 {
                let message = Message(string: text, sent: true)
                messages.append(message)
                textField.text = ""
            }
        }
        tableView.reloadData()
    }

    //MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatCell
        if messages[indexPath.row].sent == true {
            cell.showOutgoingMessage(color: UIColor.purple, text: messages[indexPath.row].string)
        } else {
            cell.showIncomingMessage(color: UIColor.orange, text: messages[indexPath.row].string)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }

    func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400.0
    }

    func scrollToBottomOfChat() {
        if messages.count != 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }

    //MARK:- TextField Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        send(self.sendButton)
        self.view.endEditing(true)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        sendButton.isEnabled = true
        sendButton.tintColor = UIColor.blue
        let offset = CGPoint(x: 0, y: self.tableView.bounds.size.height - self.tableView.contentSize.height)
        tableView.setContentOffset(offset, animated: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        sendButton.isEnabled = false
        sendButton.tintColor = .lightGray
    }
}


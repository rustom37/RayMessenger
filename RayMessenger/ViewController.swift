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
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    var messages: [Message] = [Message(string: "Hello, How are you?", sent: false), Message(string: "I'm fine.", sent: true), Message(string: "What did you do today?", sent: false), Message(string: "I went to the Grocery store and bought some potato chips", sent: true), Message(string: "Did you buy me some too? 🥔", sent: false)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "chatCell")
        sendButton.tintColor = UIColor.green

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        configureTableView()
        tableView.reloadData()
    }

    // MARK: - Send Messages
    @IBAction func send(_ sender: Any) {
        if let text = textField.text {
            if text.count > 0 {
                let message = Message(string: text, sent: true)
                messages.append(message)
                textField.text = ""
                tableView.insertRows(at: [IndexPath(row: messages.count-1, section: 0)], with: .none)
            }
        }
        scrollToBottomOfChat()
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
//        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }

    func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
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
        sendButton.tintColor = UIColor.green
        moveTextField(textField, moveDistance: -208, up: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        sendButton.isEnabled = false
        sendButton.tintColor = .lightGray
        moveTextField(textField, moveDistance: -208, up: false)
    }

    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)

        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        view.endEditing(true)
//    }
}


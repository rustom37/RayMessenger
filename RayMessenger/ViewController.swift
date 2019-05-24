//
//  ViewController.swift
//  RayMessenger
//
//  Created by Steve Rustom on 5/15/19.
//  Copyright © 2019 Steve Rustom. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    var messages: [Message] = [Message(string: "Hello, How are you?", sent: false, timeSent: Date()), Message(string: "I'm fine.", sent: true, timeSent: Date()), Message(string: "What did you do today?", sent: false, timeSent: Date()), Message(string: "I went to the Grocery store and bought some potato chips", sent: true, timeSent: Date()), Message(string: "Did you buy me some too? 🥔", sent: false, timeSent: Date())]
    let sideManager = SideManager.shared

    var originalCenter = CGPoint()
    var currentSwipingCell: UITableViewCell?
    var isSwipeSuccessful = false
    var touch = CGPoint()

    static let MAX_TRANS_X: CGFloat = 30.0

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0

        textField.delegate = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "chatCell")
        tableView.keyboardDismissMode = .interactive

        let pRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pRecognizer.delegate = self
        tableView.addGestureRecognizer(pRecognizer)
        setupSideManagerRightSide()
    }

    // MARK: - TableView Pan Handling
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        touch = recognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: touch)
        if let indexPath = indexPath {
            let model = messages[indexPath.row]
            if currentSwipingCell == nil, model.sent == false { return }
        }
        if recognizer.state == .began {
            guard let indexPath = indexPath else { return }
            guard let cell = tableView.cellForRow(at: indexPath) as? ChatCell else { return }
            originalCenter = cell.center
            currentSwipingCell = cell
            tableView.isScrollEnabled = false
        } else if recognizer.state == .changed {
            if let currentSwipingCell = currentSwipingCell {
                var translation = recognizer.translation(in: currentSwipingCell)
                if translation.x > 0 { translation.x = 0 }
                let translationValue = max(translation.x, -ViewController.MAX_TRANS_X)
                var newAlpha = 1.0 - (abs(translationValue*0.7) / ViewController.MAX_TRANS_X)
                if newAlpha < 0.4 { newAlpha = 0.4 }
                tableView.alpha = newAlpha
                currentSwipingCell.center = CGPoint(x: originalCenter.x + translationValue, y: originalCenter.y)
                isSwipeSuccessful = currentSwipingCell.frame.origin.x < -currentSwipingCell.frame.size.width / 3.0
            }
        } else {
            tableView.isScrollEnabled = true
            tableView.alpha = 1.0
            if let currentSwipingCell = currentSwipingCell {
                let originalFrame = CGRect(x: 0, y: currentSwipingCell.frame.origin.y, width: currentSwipingCell.bounds.size.width, height: currentSwipingCell.bounds.size.height)
                UIView.animate(withDuration: isSwipeSuccessful ? 1.5 : 0.2, animations: { currentSwipingCell.frame = originalFrame })
            }
            currentSwipingCell = nil
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    fileprivate func setupSideManagerRightSide() {
        sideManager.sideRightNavigationController = storyboard!.instantiateViewController(withIdentifier: "RightNavigationController") as? UISideNavigationController
        sideManager.sideAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        sideManager.sideAnimationBackgroundColor = UIColor.white
    }

    // MARK: - Send Messages
    @IBAction func send(_ sender: Any) {
        if let text = textField.text {
            if text.count > 0 {
                let message = Message(string: text, sent: true, timeSent: Date())
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
        let date = "\(Calendar.current.component(.hour, from: messages[indexPath.row].timeSent)):\(Calendar.current.component(.minute, from: messages[indexPath.row].timeSent))"
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatCell
        if messages[indexPath.row].sent == true {
            cell.showOutgoingMessage(color: UIColor.purple, text: messages[indexPath.row].string, time: date)
        } else {
            cell.showIncomingMessage(color: UIColor.orange, text: messages[indexPath.row].string, time: date)
        }
//        cell.delegate = self
        cell.selectionStyle = .none
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
        let moveDuration = 0.2
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)

        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}

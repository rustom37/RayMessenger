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
    var newCell: ChatCell?
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
        tableView.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "chatCell")
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
            newCell = Bundle.main.loadNibNamed("ChatCell", owner: self, options: nil)?[0] as? ChatCell
            self.view.addSubview(newCell!)
            newCell?.translatesAutoresizingMaskIntoConstraints = false
//            newCell?.widthAnchor.constraint(equalTo: cell.widthAnchor, multiplier: 1.0, constant: 0.0).isActive = true
//            newCell?.heightAnchor.constraint(equalTo: cell.heightAnchor, multiplier: 1.0, constant: 0.0).isActive = true
//            newCell?.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
//            newCell?.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
//            newCell?.frame = CGRect(x: newCell?.frame.origin.x ?? 0.0, y: newCell?.frame.origin.y ?? 0.0, width: cell.bounds.size.width, height: cell.bounds.size.height)
            let message = messages[indexPath.row]
            let date = "\(Calendar.current.component(.hour, from: message.timeSent)):\(Calendar.current.component(.minute, from: message.timeSent))"
            if message.sent == true {
                newCell?.showOutgoingMessage(color: UIColor.purple, text: message.string, time: date)
            } else {
                newCell?.showIncomingMessage(color: UIColor.orange, text: message.string, time: date)
            }
            newCell?.selectionStyle = .none



//            let height = newCell?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
//            var headerFrame = newCell?.frame
//
//            //Comparison necessary to avoid infinite loop
//            if height != headerFrame?.size.height {
//                headerFrame?.size.height = height ?? 0.0
//                newCell?.frame = headerFrame!
//            }
//            newCell?.alpha = 1.0
//            currentSwipingCell?.alpha = 0.0
            tableView.isScrollEnabled = false
        } else if recognizer.state == .changed {
            if let newCell = newCell {
                var translation = recognizer.translation(in: currentSwipingCell)
                if translation.x > 0 { translation.x = 0 }
                let translationValue = max(translation.x, -ViewController.MAX_TRANS_X)
                var newAlpha = 1.0 - (abs(translationValue * 0.7) / ViewController.MAX_TRANS_X)
                if newAlpha < 0.4 { newAlpha = 0.4 }
                tableView.alpha = newAlpha
                newCell.alpha = 1.0
                newCell.center = tableView.convert(CGPoint(x: originalCenter.x + translationValue, y: originalCenter.y), to: self.view)
                isSwipeSuccessful = (currentSwipingCell?.frame.origin.x)! < -(currentSwipingCell?.frame.size.width)! / 3.0
            }
            currentSwipingCell?.alpha = 0.0
        } else {
            tableView.isScrollEnabled = true
            tableView.alpha = 1.0
//            newCell?.alpha = 0.0
//            print("current swiping cell y: \(currentSwipingCell?.frame.origin.y)")
            if let currentSwipingCell = newCell {
                guard let indexPath = indexPath else { return }
//                let originalFrame = CGRect(x: 0, y: currentSwipingCell.frame.origin.y, width: currentSwipingCell.bounds.size.width, height: currentSwipingCell.bounds.size.height)
                let f = tableView.rectForRow(at: indexPath)
                let frame = tableView.convert(f, to: tableView.superview)
//                print("new cell y: \(currentSwipingCell.frame.origin.y)")
                UIView.animate(withDuration: isSwipeSuccessful ? 1.5 : 0.2, animations: {
                    currentSwipingCell.frame = frame
                }) { (finished) in
                    if finished {
                        self.newCell?.removeFromSuperview()
                        self.newCell = nil
                        self.currentSwipingCell?.alpha = 1.0
                        self.currentSwipingCell = nil
                    }
                }
            }
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
        let message = messages[indexPath.row]
        let date = "\(Calendar.current.component(.hour, from: message.timeSent)):\(Calendar.current.component(.minute, from: message.timeSent))"
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatCell
        if message.sent == true {
            cell.showOutgoingMessage(color: UIColor.purple, text: message.string, time: date)
        } else {
            cell.showIncomingMessage(color: UIColor.orange, text: message.string, time: date)
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
        send(self.sendButton as Any)
        self.view.endEditing(true)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        sendButton.isEnabled = true
//        sendButton.tintColor = .green
//        moveTextField(textField, moveDistance: -208, up: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        sendButton.isEnabled = false
        sendButton.tintColor = .lightGray
//        moveTextField(textField, moveDistance: -208, up: false)
    }

//    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
//        let moveDuration = 0.2
//        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
//
//        UIView.beginAnimations("animateTextField", context: nil)
//        UIView.setAnimationBeginsFromCurrentState(true)
//        UIView.setAnimationDuration(moveDuration)
//        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
//        UIView.commitAnimations()
//    }
}

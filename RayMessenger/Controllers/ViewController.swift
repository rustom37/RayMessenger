//
//  ViewController.swift
//  RayMessenger
//
//  Created by Steve Rustom on 5/15/19.
//  Copyright © 2019 Steve Rustom. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {
    enum SlideOutState {
        case nothingExpanded
        case rightPanelExpanded
        case expanding
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    var messages: [Message] = [Message(string: "Hello, How are you?", sent: false, timeSent: Date()), Message(string: "I'm fine.", sent: true, timeSent: Date()), Message(string: "What did you do today?", sent: false, timeSent: Date()), Message(string: "I went to the Grocery store and bought some potato chips", sent: true, timeSent: Date()), Message(string: "Did you buy me some too? 🥔", sent: false, timeSent: Date())]

    var originalCenter = CGPoint()
    var currentSwipingCell: UITableViewCell?
    var newCell: ChatCell?
    var isSwipeSuccessful = false
    var touch = CGPoint()

    static let MAX_TRANS_X: CGFloat = 30.0

    var currentState: SlideOutState = .nothingExpanded {
        didSet {
            let shouldShowShadow = currentState != .nothingExpanded
            showShadowForCenterViewController(shouldShowShadow)
        }
    }

    var rightViewController: MessageInformationViewController?

    var centerNavigationController: UINavigationController!

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

        centerNavigationController = storyboard?.instantiateViewController(withIdentifier: "RightNavigationController") as? UINavigationController

        let pRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pRecognizer.delegate = self
        tableView.addGestureRecognizer(pRecognizer)
    }

    // MARK: - TableView Pan Handling
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        touch = recognizer.location(in: tableView)
        
        let gestureIsDraggingFromRightToLeft = (recognizer.velocity(in: view).x < 0)

        let indexPath = tableView.indexPathForRow(at: touch)
        if let indexPath = indexPath {
            let model = messages[indexPath.row]
            if currentSwipingCell == nil, model.sent == false { return }
        }

        if recognizer.state == .began {

            guard let indexPath = indexPath else { return }
            guard let cell = tableView.cellForRow(at: indexPath) as? ChatCell else { return }
            if !cell.message.frame.contains(tableView.convert(touch, to: cell.contentView)) { return }

            originalCenter = cell.center
            currentSwipingCell = cell
            newCell = Bundle.main.loadNibNamed("ChatCell", owner: self, options: nil)?[0] as? ChatCell
            self.view.addSubview(newCell!)

            let message = messages[indexPath.row]
            let date = "\(Calendar.current.component(.hour, from: message.timeSent)):\(Calendar.current.component(.minute, from: message.timeSent))"
            if message.sent == true {
                newCell?.showOutgoingMessage(color: UIColor.purple, text: message.string, time: date)
            } else {
                newCell?.showIncomingMessage(color: UIColor.orange, text: message.string, time: date)
            }
            newCell?.selectionStyle = .none
            tableView.isScrollEnabled = false

            if currentState == .nothingExpanded {
                if gestureIsDraggingFromRightToLeft {
                    addRightPanelViewController()
                    showShadowForCenterViewController(true)
                    currentState = .expanding
                }
            }

            rightViewController?.messageReceived = message

        } else if recognizer.state == .changed {

            if let newCell = newCell {
                var translation = recognizer.translation(in: currentSwipingCell)
                if translation.x > 0 { translation.x = 0 }
                let translationValue = max(translation.x, -ViewController.MAX_TRANS_X)
                if translationValue == -ViewController.MAX_TRANS_X {
                    if currentState == .expanding {
                        if let rview = recognizer.view {
                            rview.center.x = rview.center.x + recognizer.translation(in: view).x
                        }
                    }
                }

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

            if let currentSwipingCell = newCell {
                guard let indexPath = indexPath else { return }
                let f = tableView.rectForRow(at: indexPath)
                let frame = tableView.convert(f, to: tableView.superview)
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
            collapseSidePanel()
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - Rightside Slide Panel
    func toggleRightPanel() {
        let notAlreadyExpanded = (currentState != .rightPanelExpanded)

        if notAlreadyExpanded {
            addRightPanelViewController()
        }

        animateRightPanel(shouldExpand: notAlreadyExpanded)
    }

    func addRightPanelViewController() {
        guard rightViewController == nil else { return }

        if let vc = storyboard?.instantiateViewController(withIdentifier: "messageInfo") as? MessageInformationViewController {
            addChildSidePanelController(vc)
            rightViewController = vc
        }
    }

    func animateRightPanel(shouldExpand: Bool) {
        if shouldExpand {
            currentState = .rightPanelExpanded
            animateCenterPanelXPosition(targetPosition: -centerNavigationController.view.frame.width)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { _ in
                self.currentState = .nothingExpanded

                self.rightViewController?.view.removeFromSuperview()
                self.rightViewController = nil
            }
        }
    }

    func collapseSidePanel() {
        switch currentState {
        case .rightPanelExpanded:
            toggleRightPanel()
        default:
            break
        }
    }

    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut, animations: {
                        self.centerNavigationController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }

    func addChildSidePanelController(_ sidePanelController: MessageInformationViewController) {
        view.insertSubview(sidePanelController.view, at: 0)

        addChild(sidePanelController)
        sidePanelController.didMove(toParent: self)
    }

    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
        if shouldShowShadow {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
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
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        sendButton.isEnabled = false
        sendButton.tintColor = .lightGray
    }
}

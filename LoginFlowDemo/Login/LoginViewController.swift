//
//  LoginViewController.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 10/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import UIKit

final class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: Responding to View Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startObservingKeyboard()
        validateInput()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopObservingKeyboard()
    }
    
    
    // MARK: Presenting Keyboard and Handling Editing
    
    @IBOutlet weak var bottomContainerConstraint: NSLayoutConstraint!
    private var notificationObservers = [NSObjectProtocol]()
    
    private func startObservingKeyboard() {
        let keyboardAppeared: ((Notification, NSLayoutConstraint, UIView) -> Void) = { notification, constraint, containerView in
            guard let frame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
            guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
            constraint.constant = frame.height
            UIView.animate(withDuration: duration) {
                containerView.layoutIfNeeded()
            }
        }
        notificationObservers.append(NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: .main) { [weak self] (notification) in
            guard let closureSelf = self else { return }
            keyboardAppeared(notification, closureSelf.bottomContainerConstraint, closureSelf.view)
        })
        notificationObservers.append(NotificationCenter.default.addObserver(forName: .UIKeyboardDidChangeFrame, object: nil, queue: .main) { [weak self] (notification) in
            guard let closureSelf = self else { return }
            keyboardAppeared(notification, closureSelf.bottomContainerConstraint, closureSelf.view)
        })
        notificationObservers.append(NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: .main) { [weak self] (notification) in
            guard let closureSelf = self else { return }
            guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
            closureSelf.bottomContainerConstraint.constant = 0
            UIView.animate(withDuration: duration) {
                closureSelf.view.layoutIfNeeded()
            }
        })
        
        notificationObservers.append(NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: nil, queue: .main, using: { [weak self] (notification) in
            self?.validateInput()
        }))
    }
    
    private func stopObservingKeyboard() {
        notificationObservers.forEach({ NotificationCenter.default.removeObserver($0) })
    }
    
    private func validateInput() {
        let canSignIn: Bool = {
            guard (emailTextField.text?.count ?? 0) > 0 else { return false }
            guard (passwordTextField.text?.count ?? 0) > 0 else { return false }
            return true
        }()
        loginButton.isEnabled = canSignIn
        loginButton.backgroundColor = canSignIn ? UIColor.coolGreen : UIColor.lightGray
    }
    
    
    // MARK: Performing Logging
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func login(_ sender: Any) {
        print("Perform logging with email \(String(describing: emailTextField.text)).")
    }
}

extension LoginViewController: Navigatable {
    var needsNavigationBar: Bool {
        return true
    }
}

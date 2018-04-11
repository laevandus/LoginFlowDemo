//
//  LoginViewController.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 10/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import UIKit

final class LoginViewController: UIViewController, UITextFieldDelegate, Networking {

    // MARK: Responding to View Events
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardVisibilityObserver = {
            let observer = KeyboardVisibilityHandler()
            observer.keyboardWillHideHandler = { [weak self] duration in
                guard let closureSelf = self else { return }
                closureSelf.containerBottomConstraint.constant = 0
                UIView.animate(withDuration: duration) {
                    closureSelf.view.layoutIfNeeded()
                }
            }
            observer.keyboardWillShowHandler = { [weak self] frame, duration in
                guard let closureSelf = self else { return }
                closureSelf.containerBottomConstraint.constant = frame.height
                UIView.animate(withDuration: duration) {
                    closureSelf.view.layoutIfNeeded()
                }
            }
            return observer
        }()
        textFieldObserver = NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: nil, queue: .main, using: { [weak self] (notification) in
            self?.validateInput()
        })
        validateInput()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboardVisibilityObserver = nil
        if let observer = textFieldObserver {
            NotificationCenter.default.removeObserver(observer)
            textFieldObserver = nil
        }
    }
    
    
    // MARK: Handling Editing and Validating Input
    
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    private var keyboardVisibilityObserver: KeyboardVisibilityHandler? = nil
    private var textFieldObserver: NSObjectProtocol? = nil
    
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
        let credentials = AccountCredentials(email: "x@y.z", password: "abc")
        let resource = Resource<AccountCredentials>(content: credentials, path: "/login/")
        webClient?.load(resource, completionHandler: { (response, error) in
            print("Logging in finished with response \(String(describing: response)) and error \(String(describing: error)).")
        })
    }
    
    
    // MARK: Networking
    
    var webClient: WebClient? = nil
}

extension LoginViewController: Navigatable {
    var needsNavigationBar: Bool {
        return true
    }
}

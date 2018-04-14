//
//  LoginViewController.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 10/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import UIKit

final class LoginViewController: UIViewController, UITextFieldDelegate, AccountLogging {

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
        textFieldObserver = NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: nil, queue: .main, using: { [weak self] (_) in
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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var loginService: LoginService? = nil
    
    @IBAction func login(_ sender: Any) {
        guard let loginService = loginService else { fatalError() }
        view.window?.endEditing(true)
        let controls = [UIControl](arrayLiteral: emailTextField, passwordTextField, loginButton)
        controls.forEach({ $0.isEnabled = false })
        activityIndicator.startAnimating()
        
        let credentials: LoginCredentials = {
            let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return LoginCredentials(email: email, password: password)
        }()
        loginService.login(with: credentials, completionHandler: { [weak self] (error) in
            guard let closureSelf = self else { return }
            controls.forEach({ $0.isEnabled = true })
            closureSelf.activityIndicator.stopAnimating()
            
            guard let error = error else {
                closureSelf.performSegue(withIdentifier: "success", sender: closureSelf)
                return
            }
            
            let alert: UIAlertController = {
                let buttonTitle = NSLocalizedString("ButtonTitle_OK", comment: "Button title for dismissing an alert.")
                let alert = UIAlertController(title: error.localizedFailureReason, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
                return alert
            }()
            closureSelf.present(alert, animated: true, completion: nil)
        })
    }
}

extension LoginViewController: Navigatable {
    var needsNavigationBar: Bool {
        return true
    }
}

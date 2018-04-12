//
//  SignUpAccountViewController.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 10/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import UIKit

final class SignUpAccountViewController: UIViewController, AccountCoordinator {

    // MARK: Responding to View Events
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
            self?.updateTitle()
        })
        validateInput()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.window?.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboardVisibilityObserver = nil
        if let observer = textFieldObserver {
            NotificationCenter.default.removeObserver(observer)
            textFieldObserver = nil
        }
    }

    
    // MARK: Managing the Check Box
    
    @IBOutlet weak var checkBoxButton: UIButton!
    
    @IBAction func toggleTermsAndServices(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        button.isSelected = !button.isSelected
        button.setBackgroundImage(button.isSelected ? #imageLiteral(resourceName: "CheckBoxSelected") : #imageLiteral(resourceName: "CheckBoxUnselected") , for: .normal)
        validateInput()
    }
    
    
    // MARK: Handling Editing and Validating Input
    
    private var keyboardVisibilityObserver: KeyboardVisibilityHandler? = nil
    private var textFieldObserver: NSObjectProtocol? = nil
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    private func validateInput() {
        let canContinue: Bool = {
            guard (emailTextField.text?.count ?? 0) > 0 else { return false }
            guard (passwordTextField.text?.count ?? 0) > 0 else { return false }
            guard checkBoxButton.isSelected else { return false }
            return true
        }()
        nextButton.isEnabled = canContinue
        nextButton.backgroundColor = canContinue ? UIColor.coolGreen : UIColor.lightGray
    }
    
    private func updateTitle() {
        title = {
            let format = NSLocalizedString("RegistrationStepFormat", comment: "Title for registration view.")
            let email = emailTextField.text ?? ""
            return String(format: format, 2, 3, String(email.prefix(5))).trimmingCharacters(in: .whitespaces)
        }()
    }
    
    
    // MARK: Account Coordination
    
    private var account = Account()
    
    func filledAccount() -> Account {
        var filledAccount = account
        filledAccount.email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        filledAccount.password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        filledAccount.isTermsAndServicesAccepted = checkBoxButton.isSelected
        return filledAccount
    }
    
    func fill(_ account: Account) {
        self.account = account
    }
    
    func refreshAccountUI() {
        checkBoxButton.isSelected = account.isTermsAndServicesAccepted
        checkBoxButton.setBackgroundImage(checkBoxButton.isSelected ? #imageLiteral(resourceName: "CheckBoxSelected") : #imageLiteral(resourceName: "CheckBoxUnselected") , for: .normal)
        emailTextField.text = account.email
        passwordTextField.text = account.password
        updateTitle()
    }
}

extension SignUpAccountViewController: Navigatable {
    var needsNavigationBar: Bool {
        return true
    }
}

//
//  SignUpAddressViewController.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 10/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import UIKit

final class SignUpAddressViewController: UIViewController {

    // MARK: Responding to View Events
    
    override func loadView() {
        super.loadView()
        
        // Reduce space around picker.
        if let first = stackView.arrangedSubviews.first {
            stackView.setCustomSpacing(0, after: first)
        }
    }
    
    
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
    
    
    // MARK: Handling Editing and Validating Input
    
    @IBOutlet weak var stackView: UIStackView!
    private var keyboardVisibilityObserver: KeyboardVisibilityHandler? = nil
    private var textFieldObserver: NSObjectProtocol? = nil
    @IBOutlet var countriesController: CountriesDataSource!
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var postalIndexTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    private func validateInput() {
        let canContinue: Bool = {
            guard (cityTextField.text?.count ?? 0) > 0 else { return false }
            guard (postalIndexTextField.text?.count ?? 0) > 0 else { return false }
            return true
        }()
        registerButton.isEnabled = canContinue
        registerButton.backgroundColor = canContinue ? UIColor.coolGreen : UIColor.lightGray
    }
    
    @IBAction func register(_ sender: Any) {
        print("Perform registration.")
    }
}

extension SignUpAddressViewController: Navigatable {
    var needsNavigationBar: Bool {
        return true
    }
}

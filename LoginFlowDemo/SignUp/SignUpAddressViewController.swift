//
//  SignUpAddressViewController.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 10/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import UIKit

final class SignUpAddressViewController: UIViewController, Networking {

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
    
    
    // MARK: Registering Account
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var webClient: WebClient? = nil
    
    @IBAction func register(_ sender: Any) {
        print("Perform registration.")
        
        view.window?.endEditing(true)
        let controls = stackView.arrangedSubviews.compactMap({ $0 as? UIControl })
        controls.forEach({ $0.isEnabled = false })
        activityIndicator.startAnimating()
        
        let account = Account(email: "test@toomas.ee", password: "jeejee", country: "EE", city: cityTextField.text ?? "", postalCode: postalIndexTextField.text ?? "")
        let resource = Resource<Account>(content: account, path: "/addUser")
        webClient?.load(resource, completionHandler: { [weak self] (response, error) in
            print("Registering new account finished with response \(String(describing: response)) and error \(String(describing: error)).")
            guard let closureSelf = self else { return }
            
            controls.forEach({ $0.isEnabled = true })
            closureSelf.activityIndicator.stopAnimating()
            
            switch error {
            case .noError:
                closureSelf.performSegue(withIdentifier: "success", sender: self)
            case .invalidResponse:
                let alert: UIAlertController = {
                    let title = NSLocalizedString("Register_FailedAlert_Title", comment: "Alert title when registering a new account failed.")
                    let suggestion = NSLocalizedString("Register_FailedAlert_Suggestion", comment: "Alert suggestion when registering a new account failed.")
                    let buttonTitle = NSLocalizedString("Register_FailedAlert_ButtonTitle", comment: "Button title for dismissing an alert.")
                    let alert = UIAlertController(title: title, message: suggestion, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
                    return alert
                }()
                closureSelf.present(alert, animated: true, completion: nil)
            }
        })
    }
}

extension SignUpAddressViewController: Navigatable {
    var needsNavigationBar: Bool {
        return true
    }
}

//
//  SignUpAddressViewController.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 10/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import UIKit

final class SignUpAddressViewController: UIViewController, Networking, AccountCoordinator {

    // MARK: Responding to View Events
    
    override func loadView() {
        super.loadView()
        countriesController = CountriesController(pickerView: pickerView)
        pickerView.reloadAllComponents()
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.window?.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboardVisibilityObserver = nil
    }
    
    
    // MARK: Registering Account
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var postalIndexTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var countriesController: CountriesController? = nil
    private var keyboardVisibilityObserver: KeyboardVisibilityHandler? = nil
    var webClient: WebClient? = nil
    
    @IBAction func register(_ sender: Any) {
        view.window?.endEditing(true)
        let controls = stackView.arrangedSubviews.compactMap({ $0 as? UIControl })
        controls.forEach({ $0.isEnabled = false })
        activityIndicator.startAnimating()
        let account = filledAccount()
        let resource = Resource<Account>(content: account, path: "/addUser")
        webClient?.load(resource, completionHandler: { [weak self] (response, error) in
            guard let closureSelf = self else { return }
            
            controls.forEach({ $0.isEnabled = true })
            closureSelf.activityIndicator.stopAnimating()
  
            switch error {
            case .noError:
                closureSelf.performSegue(withIdentifier: "success", sender: self)
            case .invalidResponse:
                let alert: UIAlertController = {
                    let title = NSLocalizedString("Register_FailedAlert_Title", comment: "Alert title when registering a new account failed.")
                    let suggestion = NSLocalizedString("Register_FailedAlert_GenericSuggestion", comment: "Alert suggestion when registering a new account failed.")
                    let buttonTitle = NSLocalizedString("Register_FailedAlert_ButtonTitle", comment: "Button title for dismissing an alert.")
                    let alert = UIAlertController(title: title, message: suggestion, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
                    return alert
                }()
                closureSelf.present(alert, animated: true, completion: nil)
            case .custom(let customError):
                switch customError {
                case .invalidCredentials:
                    let alert: UIAlertController = {
                        let title = NSLocalizedString("Register_FailedAlert_Title", comment: "Alert title when registering a new account failed.")
                        let suggestion = NSLocalizedString("Register_FailedAlert_CheckCredentialsSuggestion", comment: "Alert suggestion when registering a new account failed as credentials are invalid.")
                        let buttonTitle = NSLocalizedString("Register_FailedAlert_ButtonTitle", comment: "Button title for dismissing an alert.")
                        let alert = UIAlertController(title: title, message: suggestion, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
                        return alert
                    }()
                    closureSelf.present(alert, animated: true, completion: nil)
                case .timeout:
                    break
                case .passwordTooShort:
                    let alert: UIAlertController = {
                        let title = NSLocalizedString("Register_FailedAlert_Title", comment: "Alert title when registering a new account failed.")
                        let suggestion = NSLocalizedString("Register_FailedAlert_PasswordShortSuggestion", comment: "Alert suggestion when registering new account failed.")
                        let buttonTitle = NSLocalizedString("Register_FailedAlert_ButtonTitle", comment: "Button title for dismissing an alert.")
                        let alert = UIAlertController(title: title, message: suggestion, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
                        return alert
                    }()
                    closureSelf.present(alert, animated: true, completion: nil)
                case .unknown:
                    let alert: UIAlertController = {
                        let title = NSLocalizedString("Register_FailedAlert_Title", comment: "Alert title when registering a new account failed.")
                        let suggestion = NSLocalizedString("Register_FailedAlert_GenericSuggestion", comment: "Alert suggestion when registering a new account failed.")
                        let buttonTitle = NSLocalizedString("Register_FailedAlert_ButtonTitle", comment: "Button title for dismissing an alert.")
                        let alert = UIAlertController(title: title, message: suggestion, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
                        return alert
                    }()
                    closureSelf.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    
    // MARK: Account Coordination
    
    private var account = Account()
    
    func filledAccount() -> Account {
        var filledAccount = account
        filledAccount.country = countriesController?.selectedCountryCode ?? ""
        filledAccount.city = cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        filledAccount.postalCode = postalIndexTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return filledAccount
    }
    
    func fill(_ account: Account) {
        self.account = account
    }
    
    func refreshAccountUI() {
        let countryCode = account.country
        pickerView.selectRow(countriesController?.index(ofCountry: countryCode) ?? 0, inComponent: 0, animated: false)
        cityTextField.text = account.city
        postalIndexTextField.text = account.postalCode
    }
}

extension SignUpAddressViewController: Navigatable {
    var needsNavigationBar: Bool {
        return true
    }
}

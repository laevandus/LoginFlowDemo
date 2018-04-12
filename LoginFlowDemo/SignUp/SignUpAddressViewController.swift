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
        webClient?.registrationService.register(filledAccount(), completionHandler: { [weak self] (error) in
            guard let closureSelf = self else { return }
            controls.forEach({ $0.isEnabled = true })
            closureSelf.activityIndicator.stopAnimating()
  
            guard let error = error else {
                closureSelf.performSegue(withIdentifier: "success", sender: self)
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
        let countryIndex: Int = {
            let countryCode = account.country.isEmpty ? Locale.current.regionCode ?? "" : account.country
            return countriesController?.index(ofCountry: countryCode) ?? 0
        }()
        pickerView.selectRow(countryIndex, inComponent: 0, animated: false)
        cityTextField.text = account.city
        postalIndexTextField.text = account.postalCode
    }
}

extension SignUpAddressViewController: Navigatable {
    var needsNavigationBar: Bool {
        return true
    }
}

extension SignUpAddressViewController: SignUpFlow {
    var controller: UIViewController { return self }
    var signUpStep: Int { return 3 }
    var titleText: String { return account.email }
}

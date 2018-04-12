//
//  RegistrationService.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 12/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import Foundation

final class RegistrationService {
    
    enum RegistrationError: Error {
        case passwordTooShort
        case invalidAccount
        case failedConnecting
    }
    
    private weak var client: WebClient?
    
    init(client: WebClient) {
        self.client = client
    }
    
    private var registrationTask: (task: URLSessionDataTask, completionHandler: (RegistrationError?) -> Void)? = nil
    private var retriesRemaining: Int = 3
    
    func register(_ account: Account, completionHandler: @escaping (RegistrationError?) -> Void) {
        guard registrationTask == nil else { fatalError("Account registration is already in progress.") }
        retriesRemaining = 3
        tryRegistering(account: account, completionHandler: completionHandler)
    }
    
    private func tryRegistering(account: Account, completionHandler: @escaping (RegistrationError?) -> Void) {
        guard let client = client else { fatalError("Client is not available.") }
        let resource = Resource<Account>(content: account, path: "/addUser")
        let task = client.load(resource, completionHandler: { [weak self] (response, error) in
            guard let closureSelf = self else { return }
            switch error {
            case .noError:
                print("Account for '\(account.email)' was created successfully.")
                closureSelf.registrationTask?.completionHandler(nil)
                closureSelf.registrationTask = nil
            case .custom(let custom):
                switch custom {
                case .timeout:
                    if closureSelf.retriesRemaining > 0 {
                        closureSelf.retriesRemaining -= 1
                        print("Retring registering account… (retries remaining: \(closureSelf.retriesRemaining))")
                        closureSelf.tryRegistering(account: account, completionHandler: completionHandler)
                    }
                    else {
                        closureSelf.registrationTask?.completionHandler(.failedConnecting)
                        closureSelf.registrationTask = nil
                    }
                case .passwordTooShort:
                    closureSelf.registrationTask?.completionHandler(.passwordTooShort)
                    closureSelf.registrationTask = nil
                case .invalidCredentials:
                    closureSelf.registrationTask?.completionHandler(.invalidAccount)
                    closureSelf.registrationTask = nil
                case .unknown:
                    closureSelf.registrationTask?.completionHandler(.failedConnecting)
                    closureSelf.registrationTask = nil
                }
            default:
                closureSelf.registrationTask?.completionHandler(.failedConnecting)
                closureSelf.registrationTask = nil
            }
        })
        registrationTask = (task: task, completionHandler: completionHandler)
    }
}

extension RegistrationService.RegistrationError {
    var localizedFailureReason: String {
        return NSLocalizedString("RegistrationFailureReason", comment: "Account registration failure reason.")
    }
    
    var localizedDescription: String {
        switch self {
        case .failedConnecting:
            return NSLocalizedString("RegistrationFailureDescription_Generic", comment: "Account registration failure description when failing to connect.")
        case .invalidAccount:
            return NSLocalizedString("RegistrationFailureDescription_InvalidCredentials", comment: "Account registration failure description when account is invalid.")
        case .passwordTooShort:
            return NSLocalizedString("RegistrationFailureDescription_TooShortPassword", comment: "Account registration failure description when password is too short.")
        }
    }
}

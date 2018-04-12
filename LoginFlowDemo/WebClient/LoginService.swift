//
//  LoginService.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 12/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import Foundation

final class LoginService {
    
    enum LoginError: Error {
        case failedConnecting
        case invalidCredentials
    }
    
    private weak var client: WebClient?
    
    init(client: WebClient) {
        self.client = client
    }
    
    private var loginTask: (task: URLSessionDataTask, completionHandler: (LoginError?) -> Void)? = nil
    private var retriesRemaining: Int = 3
    
    func login(with credentials: LoginCredentials, completionHandler: @escaping (LoginError?) -> Void) {
        guard loginTask == nil else { fatalError("Login is already in progress.") }
        retriesRemaining = 3
        tryLoggingIn(with: credentials, completionHandler: completionHandler)
    }
    
    private func tryLoggingIn(with credentials: LoginCredentials, completionHandler: @escaping (LoginError?) -> Void) {
        guard let client = client else { fatalError("Client is not available.") }
        let resource = Resource<LoginCredentials>(content: credentials, path: "/login")
        let task = client.load(resource, completionHandler: { [weak self] (response, error) in
            guard let closureSelf = self else { return }
            switch error {
            case .noError:
                print("Account for '\(credentials.email)' was logged in successfully.")
                closureSelf.loginTask?.completionHandler(nil)
                closureSelf.loginTask = nil
            case .custom(let custom):
                switch custom {
                case .timeout:
                    if closureSelf.retriesRemaining > 0 {
                        closureSelf.retriesRemaining -= 1
                        print("Retring logging in account… (retries remaining: \(closureSelf.retriesRemaining))")
                        closureSelf.tryLoggingIn(with: credentials, completionHandler: completionHandler)
                    }
                    else {
                        closureSelf.loginTask?.completionHandler(.failedConnecting)
                        closureSelf.loginTask = nil
                    }
                case .invalidCredentials:
                    closureSelf.loginTask?.completionHandler(.invalidCredentials)
                    closureSelf.loginTask = nil
                case .passwordTooShort, .unknown:
                    closureSelf.loginTask?.completionHandler(.failedConnecting)
                    closureSelf.loginTask = nil
                }
            default:
                closureSelf.loginTask?.completionHandler(.failedConnecting)
                closureSelf.loginTask = nil
            }
        })
        loginTask = (task: task, completionHandler: completionHandler)
    }
}

extension LoginService.LoginError {
    var localizedFailureReason: String {
        return NSLocalizedString("LoginFailureReason", comment: "Account registration failure reason.")
    }
    
    var localizedDescription: String {
        switch self {
        case .failedConnecting:
            return NSLocalizedString("LoginFailureDescription_Generic", comment: "Login registration failure description when failing to connect.")
        case .invalidCredentials:
            return NSLocalizedString("LoginFailureDescription_InvalidCredentials", comment: "Login failure description when credentials are invalid.")
        }
    }
}

//
//  AppDelegate.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 10/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let dependencies = Dependencies()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        guard let navigationController = window?.rootViewController as? UINavigationController else {
            fatalError("Initial view controller is not navigation controller.")
        }
        navigationController.delegate = dependencies.navigationHandler
        dependencies.navigationHandler.willNavigateHandler = { [weak self] viewController in
            (viewController as? AccountLogging)?.loginService = self?.dependencies.loginService
            (viewController as? AccountRegistration)?.registrationService = self?.dependencies.registrationService
        }
        
        return true
    }
}

private struct Dependencies {
    private let webClient = WebClient(baseURL: URL(string: "https://poco-test.herokuapp.com")!)
    let navigationHandler = NavigationHandler()
    let loginService: LoginService
    let registrationService: RegistrationService
    
    init() {
        loginService = LoginService(client: webClient)
        registrationService = RegistrationService(client: webClient)
    }
}


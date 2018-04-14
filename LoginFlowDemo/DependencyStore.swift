//
//  DependencyStore.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 14/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import Foundation

struct DependencyStore {
    private let webClient = WebClient(baseURL: URL(string: "https://poco-test.herokuapp.com")!)
    let navigationHandler = NavigationHandler()
    let loginService: LoginService
    let registrationService: RegistrationService
    
    init() {
        loginService = LoginService(client: webClient)
        registrationService = RegistrationService(client: webClient)
    }
}

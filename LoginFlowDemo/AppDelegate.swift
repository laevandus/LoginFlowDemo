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
        return true
    }
}

private struct Dependencies {
    let navigationHandler = NavigationHandler()
}


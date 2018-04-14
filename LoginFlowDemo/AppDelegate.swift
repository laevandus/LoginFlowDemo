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
    
    private var scenePresenter: ScenePresenter? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        scenePresenter = ScenePresenter(window: window, store: DependencyStore())
        scenePresenter?.presentWelcome()
        window.makeKeyAndVisible()
        return true
    }
}

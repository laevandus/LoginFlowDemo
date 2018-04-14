//
//  ScenePresenter.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 14/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import UIKit

final class ScenePresenter {
    
    let store: DependencyStore
    let window: UIWindow
    
    init(window: UIWindow, store: DependencyStore) {
        self.store = store
        self.window = window
    }
    
    private var storyboard: UIStoryboard { return UIStoryboard(name: "Main", bundle: nil) }
    
    func presentWelcome() {
        guard let navigationController = storyboard.instantiateViewController(withIdentifier: "welcome") as? UINavigationController else { fatalError() }
        navigationController.delegate = store.navigationHandler

        store.navigationHandler.navigationPrepareHandler = { [weak self] (fromViewController, toViewController) in
            if let next = toViewController as? AccountCoordinator {
                if let current = fromViewController as? AccountCoordinator {
                    next.fill(current.filledAccount())
                }
            }
            
            (toViewController as? AccountLogging)?.loginService = self?.store.loginService
            (toViewController as? AccountRegistration)?.registrationService = self?.store.registrationService
        }
        
        store.navigationHandler.navigationWillShowHandler = { (viewController) in
            if let navigatable = viewController as? Navigatable {
                navigationController.isNavigationBarHidden = navigatable.needsNavigationBar ? false : true
            }
            else {
                navigationController.isNavigationBarHidden = true
            }
            
            (viewController as? AccountCoordinator)?.refreshAccountUI()
            (viewController as? ScenePresentation)?.presenter = self
            (viewController as? SignUpFlow)?.updateTitle()
        }
        
        window.rootViewController = navigationController
    }
    
    func presentAccountView() {
        window.rootViewController = storyboard.instantiateViewController(withIdentifier: "accountView")

    }
    
    func presentAccountWelcome() {
        window.rootViewController = storyboard.instantiateViewController(withIdentifier: "registrationSuccess")
    }
}

protocol ScenePresentation: class {
    var presenter: ScenePresenter? { get set }
}

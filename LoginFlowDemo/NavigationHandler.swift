//
//  NavigationHandler.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 10/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import UIKit

final class NavigationHandler: NSObject, UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let navigatable = viewController as? Navigatable {
            navigationController.isNavigationBarHidden = navigatable.needsNavigationBar ? false : true
        }
        else {
            navigationController.isNavigationBarHidden = true
        }
        
        (viewController as? AccountCoordinator)?.refreshAccountUI()
        (viewController as? SignUpFlow)?.updateTitle()
        
        willNavigateHandler?(viewController)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromViewController: UIViewController, to toViewController: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let next = toViewController as? AccountCoordinator {
            if let current = fromViewController as? AccountCoordinator {
                next.fill(current.filledAccount())
            }
        }
        
        return nil
    }
    
    var willNavigateHandler: ((UIViewController) -> Void)? = nil
}

protocol Navigatable {
    var needsNavigationBar: Bool { get }
}

protocol AccountCoordinator {
    func filledAccount() -> Account
    func fill(_ account: Account)
    func refreshAccountUI()
}

protocol SignUpFlow {
    var controller: UIViewController { get }
    var signUpStep: Int { get }
    var titleText: String { get }
}

extension SignUpFlow {
    func updateTitle() {
        controller.title = {
            let format = NSLocalizedString("RegistrationStepFormat", comment: "Title for registration view.")
            return String(format: format, signUpStep, 3, String(titleText.prefix(5))).trimmingCharacters(in: .whitespaces)
        }()
    }
}

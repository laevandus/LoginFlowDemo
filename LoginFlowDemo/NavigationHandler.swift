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
        navigationWillShowHandler?(viewController)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromViewController: UIViewController, to toViewController: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        navigationPrepareHandler?(fromViewController, toViewController)
        return nil
    }
    
    var navigationPrepareHandler: ((UIViewController, UIViewController) -> Void)? = nil
    var navigationWillShowHandler: ((UIViewController) -> Void)? = nil
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

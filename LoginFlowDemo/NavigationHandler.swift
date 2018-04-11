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
        willNavigate?(viewController)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let nextAccountCoordinator = toVC as? AccountCoordinator {
            if let currentAccountCoordinator = fromVC as? AccountCoordinator {
                nextAccountCoordinator.fill(currentAccountCoordinator.filledAccount())
            }
        }
        
        return nil
    }
    
    var willNavigate: ((UIViewController) -> Void)? = nil
}

protocol Navigatable {
    var needsNavigationBar: Bool { get }
}

protocol AccountCoordinator {
    func filledAccount() -> Account
    func fill(_ account: Account)
    func refreshAccountUI()
}


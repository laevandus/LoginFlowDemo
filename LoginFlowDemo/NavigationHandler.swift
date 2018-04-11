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
        
        willNavigate?(viewController)
    }
    
    var willNavigate: ((UIViewController) -> Void)? = nil
}

protocol Navigatable {
    var needsNavigationBar: Bool { get }
}


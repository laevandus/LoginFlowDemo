//
//  SignUpIntroductionViewController.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 10/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import UIKit

final class SignUpIntroductionViewController: UIViewController, AccountCoordinator {
    
    // MARK: Responding to View Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "1/3"
    }
    
    
    // MARK: Account Coordination
    
    private var account = Account()
    
    func filledAccount() -> Account {
        return account
    }
    
    func fill(_ account: Account) {
        self.account = account
    }
    
    func refreshAccountUI() {}
}

extension SignUpIntroductionViewController: Navigatable {
    var needsNavigationBar: Bool {
        return true
    }
}

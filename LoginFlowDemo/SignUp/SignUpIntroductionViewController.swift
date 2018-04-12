//
//  SignUpIntroductionViewController.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 10/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import UIKit

final class SignUpIntroductionViewController: UIViewController, AccountCoordinator {
    
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

extension SignUpIntroductionViewController: SignUpFlow {
    var controller: UIViewController { return self }
    var signUpStep: Int { return 1 }
    var titleText: String { return "" }
}

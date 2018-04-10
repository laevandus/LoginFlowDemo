//
//  KeyboardVisibilityHandler.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 10/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import Foundation
import UIKit

final class KeyboardVisibilityHandler {
    
    private var notificationObservers = [NSObjectProtocol]()
    
    init() {
        notificationObservers.append(NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: .main) { [weak self] (notification) in
            guard let closureSelf = self else { return }
            guard let frame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
            guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
            closureSelf.keyboardWillShowHandler?(frame, duration)
        })
        notificationObservers.append(NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: .main) { [weak self] (notification) in
            guard let closureSelf = self else { return }
            guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
            closureSelf.keyboardWillHideHandler?(duration)
        })
    }
    
    deinit {
        notificationObservers.forEach({ NotificationCenter.default.removeObserver($0) })
    }
    
    var keyboardWillHideHandler: ((TimeInterval) -> Void)? = nil
    var keyboardWillShowHandler: ((CGRect, TimeInterval) -> Void)? = nil
}

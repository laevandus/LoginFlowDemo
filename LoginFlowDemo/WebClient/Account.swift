//
//  Account.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 11/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import Foundation

struct Account: Codable {
    let email: String
    let password: String
    var country: String
    var city: String
    var postalCode: String
    
    enum CodingKeys: String, CodingKey {
        case email, password, country, city
        case postalCode = "postal_code"
    }
}

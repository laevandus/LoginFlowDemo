//
//  Resource.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 11/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import Foundation

struct Resource<T> {
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }
    
    let path: String
    let headers: [String: String]
    let method: Method
    let body: String
}

extension Resource where T: Encodable {
    init(content: T, path: String) {
        self.headers = ["Accept": "application/json",
                        "Content-Type": "application/json"]
        self.path = path
        self.method = .post
        self.body = {
            let encoder = JSONEncoder()
            let data = try! encoder.encode(content)
            return String(data: data, encoding: .utf8) ?? ""
        }()
    }
}

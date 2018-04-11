//
//  WebClient.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 10/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import Foundation

final class WebClient {
    
    let baseURL: URL
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    @discardableResult func load<T>(_ resource: Resource<T>, completionHandler: @escaping (String?, Error?) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: baseURL.appendingPathComponent(resource.path))
        request.addValue("LoginFlowDemo", forHTTPHeaderField: "User-Agent")
        request.httpMethod = resource.method.rawValue
        resource.headers.forEach { (field, value) in
            request.setValue(value, forHTTPHeaderField: field)
        }
        
        switch resource.method {
        case .get: break
        case .post:
            if let bodyData = resource.body.data(using: .utf8), bodyData.count > 0 {
                request.httpBody = bodyData
                request.setValue("\(bodyData.count)", forHTTPHeaderField: "Content-Length")
            }
        }
        
        let task = session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            guard let response = urlResponse as? HTTPURLResponse else {
                // TODO: needs custom error
                completionHandler(nil, nil)
                return
            }
            
            guard response.statusCode == 200 else {
                print("Request failed with status code \(response.statusCode).")
                completionHandler(nil, error)
                return
            }
            
            if let data = data, let string = String(data: data, encoding: .utf8) {
                completionHandler(string, error)
            }
            else {
                completionHandler(nil, error)
            }
        }
        task.resume()
        return task
    }

    
    // MARK: URL Session
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: .main)
    }()
}

protocol Networking: class {
    var webClient: WebClient? { get set }
}

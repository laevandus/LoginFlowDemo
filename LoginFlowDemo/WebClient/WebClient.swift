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
    
    @discardableResult func load<T>(_ resource: Resource<T>, completionHandler: @escaping (String, WebClientError) -> Void) -> URLSessionDataTask {
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
        
        let task = session.dataTask(with: request) { (data, urlResponse, _) in
            guard let response = urlResponse as? HTTPURLResponse else {
                completionHandler("", .invalidResponse)
                return
            }
            
            let responseContent: String = {
                guard let data = data else { return "" }
                return String(data: data, encoding: .utf8) ?? ""
            }()
            
            if response.statusCode == 200 {
                completionHandler(responseContent, .noError)
            }
            else {
                let responseError: ErrorPayload? = {
                    guard let data = data else { return nil }
                    let decoded = try? JSONDecoder().decode(ErrorPayload.self, from: data)
                    return decoded
                }()
                if let responseError = responseError {
                    completionHandler(responseContent, .custom(responseError.customError))
                }
                else {
                    completionHandler(responseContent, .invalidResponse)
                }
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
    
    
    // MARK: Services
    
    lazy var loginService: LoginService = {
        return LoginService(client: self)
    }()
    
    lazy var registrationService: RegistrationService = {
        return RegistrationService(client: self)
    }()
}

enum WebClientError: Error {
    case noError
    case invalidResponse
    case custom(ErrorPayload.Custom)
}

struct ErrorPayload: Codable {
    let error: String
}

extension ErrorPayload {
    enum Custom: String, Decodable {
        case passwordTooShort = "err.password.too.short"
        case invalidCredentials = "err.wrong.credentials"
        case timeout = "err.timeout"
        case unknown = "err.unknown"
    }
    var customError: Custom {
        guard let customError = Custom(rawValue: error) else { return .unknown }
        return customError
    }
}

protocol Networking: class {
    var webClient: WebClient? { get set }
}

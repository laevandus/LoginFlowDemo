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
    
    private lazy var session: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: .main)
    }()
    
    @discardableResult func load<T>(_ resource: Resource<T>, completionHandler: @escaping (Data?, WebClientError) -> Void) -> URLSessionDataTask {
        let request = URLRequest(baseURL: baseURL, resource: resource)
        let task = session.dataTask(with: request) { (data, urlResponse, _) in
            guard let response = urlResponse as? HTTPURLResponse else {
                completionHandler(nil, .invalidResponse)
                return
            }
            if response.statusCode == 200 {
                completionHandler(data, .noError)
            }
            else {
                let responseError: ErrorPayload? = {
                    guard let data = data else { return nil }
                    let decoded = try? JSONDecoder().decode(ErrorPayload.self, from: data)
                    return decoded
                }()
                if let responseError = responseError {
                    completionHandler(data, .custom(responseError.customError))
                }
                else {
                    completionHandler(data, .invalidResponse)
                }
            }
        }
        task.resume()
        return task
    }
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

fileprivate extension URLRequest {
    init<T>(baseURL: URL, resource: Resource<T>) {
        self.init(url: baseURL.appendingPathComponent(resource.path))
        addValue("LoginFlowDemo", forHTTPHeaderField: "User-Agent")
        httpMethod = resource.method.rawValue
        resource.headers.forEach { (field, value) in
            setValue(value, forHTTPHeaderField: field)
        }
        switch resource.method {
        case .get:
            break
        case .post:
            if let bodyData = resource.body.data(using: .utf8), bodyData.count > 0 {
                httpBody = bodyData
                setValue("\(bodyData.count)", forHTTPHeaderField: "Content-Length")
            }
        }
    }
}

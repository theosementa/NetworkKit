//
//  BaseAPIRequester.swift
//  NetworkBestPracticesSwiftUI
//
//  Created by Theo Sementa on 03/02/2025.
//

import Foundation
import NetworkKit

extension APIRequestBuilder {
    
    var headers: [(key: String, value: String)]? {
        var header = [(String, String)]()
        header.append(("Content-Type", "application/json"))
        if isTokenNeeded {
            header.append(("Authorization", "Bearer \(TokenManager.shared.token)"))
        }
        return header
    }
    
    var urlRequest: URLRequest? {
        let urlString = NetworkPath.baseURL + path

        var components = URLComponents(string: urlString)
        if let parameters {
            components?.queryItems = parameters
        }

        guard let url = components?.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        if let headers {
            headers.forEach {
                request.addValue($0.value, forHTTPHeaderField: $0.key)
            }
        }

        if let body {
            request.httpBody = body
        }

        return request
    }
    
}

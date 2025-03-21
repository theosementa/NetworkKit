//
//  APIRequestBuilder.swift
//  NetworkKit
//
//  Created by Theo Sementa on 03/02/2025.
//

import Foundation

/// Protocol defining the structure of an API request builder.
public protocol APIRequestBuilder {
    /// The path of the API endpoint.
    var path: String { get }

    /// The HTTP method to be used for the request.
    var httpMethod: HTTPMethod { get }

    /// The query parameters to be included in the URL.
    var parameters: [URLQueryItem]? { get }

    /// Indicates whether an authentication token is required for this request.
    var isTokenNeeded: Bool { get }

    /// Additional HTTP headers to be included in the request.
    var headers: [(key: String, value: String)]? { get }

    /// The body of the request, if needed.
    var body: Data? { get }

    /// The URL request constructed from the builder's properties.
    var urlRequest: URLRequest? { get }
}

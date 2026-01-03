//
//  DeferredRequest.swift
//  NetworkKit
//
//  Created by Theo Sementa on 03/01/2026.
//

import Foundation

public struct DeferredRequest: Codable, Identifiable {
    public let id: UUID
    public let url: URL
    public let method: String
    public let headers: [String: String]
    public let body: Data?
    public let createdAt: Date
}

extension DeferredRequest {
    init?(_ request: URLRequest) {
        guard let url = request.url else { return nil }
        self.id = UUID()
        self.url = url
        self.method = request.httpMethod ?? "GET"
        self.headers = request.allHTTPHeaderFields ?? [:]
        self.body = request.httpBody
        self.createdAt = .now
    }
}

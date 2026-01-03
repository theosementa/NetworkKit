//
//  DeferredRequestStore.swift
//  NetworkKit
//
//  Created by Theo Sementa on 03/01/2026.
//

import Foundation

public protocol DeferredRequestStore {
    func load() async throws -> [DeferredRequest]
    func save(_ requests: [DeferredRequest]) async throws

    func enqueue(_ request: DeferredRequest) async throws
    func remove(_ request: DeferredRequest) async throws
    func removeAll() async throws
}

public actor FileDeferredRequestStore: DeferredRequestStore {

    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(filename: String = "deferred_requests.json") {
        let dir = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        self.fileURL = dir.appendingPathComponent(filename)
    }

    public func load() async throws -> [DeferredRequest] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("🔥 FILE DOESN'T EXIST")
            return []
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([DeferredRequest].self, from: data)
    }

    public func save(_ requests: [DeferredRequest]) async throws {
        let data = try encoder.encode(requests)
        try data.write(to: fileURL, options: .atomic)
    }

    public func enqueue(_ request: DeferredRequest) async throws {
        var requests = try await load()
        requests.append(request)
        try await save(requests)
    }

    public func remove(_ request: DeferredRequest) async throws {
        var requests = try await load()
        requests.removeAll { $0.id == request.id }
        try await save(requests)
    }

    public func removeAll() async throws {
        try await save([])
    }
}

public extension DeferredRequestStore {

    func enqueue(_ urlRequest: URLRequest) async throws {
        guard let request = DeferredRequest(urlRequest) else {
            throw NetworkError.badRequest
        }
        try await enqueue(request)
    }
    
}


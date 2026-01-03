//
//  DeferredRequestStore.swift
//  NetworkKit
//
//  Created by Theo Sementa on 03/01/2026.
//

import Foundation

public protocol DeferredRequestStore {
    func load() throws -> [DeferredRequest]
    func save(_ requests: [DeferredRequest]) throws

    func enqueue(_ request: DeferredRequest) throws
    func remove(_ request: DeferredRequest) throws
    func removeAll() throws
}


public final class FileDeferredRequestStore: DeferredRequestStore {

    private let fileURL: URL
    private let queue = DispatchQueue(label: "DeferredRequestStore.Queue")

    public init(filename: String = "deferred_requests.json") {
        let dir = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        self.fileURL = dir.appendingPathComponent(filename)
    }

    public func load() throws -> [DeferredRequest] {
        try queue.sync {
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                return []
            }
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([DeferredRequest].self, from: data)
        }
    }

    public func save(_ requests: [DeferredRequest]) throws {
        try queue.sync {
            let data = try JSONEncoder().encode(requests)
            try data.write(to: fileURL, options: .atomic)
        }
    }

    public func enqueue(_ request: DeferredRequest) throws {
        try queue.sync {
            var requests = try load()
            requests.append(request)
            try save(requests)
        }
    }

    public func remove(_ request: DeferredRequest) throws {
        try queue.sync {
            var requests = try load()
            requests.removeAll { $0.id == request.id }
            try save(requests)
        }
    }

    public func removeAll() throws {
        try queue.sync {
            try save([])
        }
    }
}

public extension DeferredRequestStore {
    func enqueue(_ urlRequest: URLRequest) throws {
        guard let request = DeferredRequest(urlRequest) else {
            throw NetworkError.badRequest
        }
        try enqueue(request)
    }
}

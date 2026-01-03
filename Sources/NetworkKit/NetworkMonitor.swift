//
//  File.swift
//  NetworkKit
//
//  Created by Theo Sementa on 03/01/2026.
//

import Foundation
import Network

public enum NetworkStatus {
    case unknown
    case connected
    case disconnected
}

@Observable
public final class NetworkMonitor: @unchecked Sendable {

    public static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    public private(set) var status: NetworkStatus = .unknown

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.status = path.status == .satisfied ? .connected : .disconnected
            }
        }
        monitor.start(queue: queue)
    }

    public var isConnected: Bool {
        status == .connected
    }
}

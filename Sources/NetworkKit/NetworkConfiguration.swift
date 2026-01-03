//
//  File.swift
//  NetworkKit
//
//  Created by Theo Sementa on 03/01/2026.
//

import Foundation

public class NetworkConfiguration {
    public static let shared = NetworkConfiguration()
    
    public var isUrlRequestStoredByDefault: Bool
    
    private init(isUrlRequestStoredByDefault: Bool = false) {
        self.isUrlRequestStoredByDefault = isUrlRequestStoredByDefault
    }
    
    public static func configure(isUrlRequestStoredByDefault: Bool = false) {
        shared.isUrlRequestStoredByDefault = isUrlRequestStoredByDefault
    }
    
}

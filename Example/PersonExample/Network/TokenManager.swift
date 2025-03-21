//
//  TokenManager.swift
//  NetworkKit
//
//  Created by Theo Sementa on 03/02/2025.
//

import Foundation

final class TokenManager: ObservableObject {
    static let shared = TokenManager()

    @Published var token: String = ""
}

extension TokenManager {
    
    func setToken(token: String) {
        self.token = token
    }
    
}

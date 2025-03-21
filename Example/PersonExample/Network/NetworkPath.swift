//
//  NetworkPath.swift
//  NetworkBestPracticesSwiftUI
//
//  Created by Theo Sementa on 03/02/2025.
//

import Foundation

struct NetworkPath {
    static let baseURL: String = "https://neopixl.com"
    
    struct Person {
        static let persons: String = "/persons"
        static func managePerson(id: Int) -> String {
            return "/persons/\(id)"
        }
        static func grantAdmin(id: Int) -> String {
            return "/persons/grant/\(id)"
        }
    }
}

//
//  NetworkKitApp.swift
//  NetworkKit
//
//  Created by Theo Sementa on 03/02/2025.
//

import SwiftUI

@main
struct NetworkKitApp: App {
    
    @StateObject private var personStore: PersonStore = .shared
    
    // MARK: -
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(personStore)
        }
    } // body
} // struct

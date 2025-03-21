//
//  ContentView.swift
//  NetworkKit
//
//  Created by Theo Sementa on 03/02/2025.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var personStore: PersonStore
    
    // MARK: -
    var body: some View {
        List(personStore.persons) { person in
            HStack {
                Text(person.firstName)
                Text(person.lastName)
            }
        }
        .task {
            await personStore.fetchPersons()
        }
    } // body
} // struct

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(PersonStore.shared)
}

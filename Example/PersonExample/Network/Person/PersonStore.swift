//
//  PersonStore.swift
//  NetworkBestPracticesSwiftUI
//
//  Created by Theo Sementa on 03/02/2025.
//

import Foundation

final class PersonStore: ObservableObject {
    static let shared = PersonStore()
    
    @Published var persons: [PersonModel] = []
}

extension PersonStore {
    
    func fetchPersons() async {
        do {
            let persons = try await PersonService.fetchAllPersons()
            self.persons = persons
        } catch {
            print("⚠️ ERROR \(error.localizedDescription)")
        }
    }
    
    func createPerson(person: PersonModel) async {
        do {
            let newPerson = try await PersonService.createPerson(person: person)
            self.persons.append(newPerson)
        } catch {
            print("⚠️ ERROR \(error.localizedDescription)")
        }
    }
    
    func updatePerson(person: PersonModel) async {
        guard let id = person.id else { return }
        
        do {
            let updatedPerson = try await PersonService.updatePerson(id: id, person: person)
            
            if let index = self.persons.firstIndex(where: { $0.id == id }) {
                self.persons[index] = updatedPerson
            }
        } catch {
            print("⚠️ ERROR \(error.localizedDescription)")
        }
    }
    
    func deletePerson(id: Int) async {
        do {
            try await PersonService.deletePerson(id: id)
        } catch {
            print("⚠️ ERROR \(error.localizedDescription)")
        }
    }
    
    func grantAdmin(id: Int) async {
        do {
            try await PersonService.grantAdminRole(id: id)
        } catch {
            print("⚠️ ERROR \(error.localizedDescription)")
        }
    }
    
}

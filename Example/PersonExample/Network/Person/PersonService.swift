//
//  PersonService.swift
//  NetworkBestPracticesSwiftUI
//
//  Created by Theo Sementa on 03/02/2025.
//

import Foundation
import NetworkKit

struct PersonService {
    
    static func fetchAllPersons() async throws -> [PersonModel] {
        return try await NetworkService.sendRequest(
            apiBuilder: PersonAPIRequester.fetchPersons,
            responseModel: [PersonModel].self
        )
    }
    
    static func fetchPerson(id: Int) async throws -> PersonModel {
        return try await NetworkService.sendRequest(
            apiBuilder: PersonAPIRequester.fetchPerson(id: id),
            responseModel: PersonModel.self
        )
    }
    
    static func createPerson(person: PersonModel) async throws -> PersonModel {
        return try await NetworkService.sendRequest(
            apiBuilder: PersonAPIRequester.createPerson(body: person),
            responseModel: PersonModel.self
        )
    }
    
    static func updatePerson(id: Int, person: PersonModel) async throws -> PersonModel {
        return try await NetworkService.sendRequest(
            apiBuilder: PersonAPIRequester.updatePerson(id: id, body: person),
            responseModel: PersonModel.self
        )
    }
    
    static func deletePerson(id: Int) async throws {
        try await NetworkService.sendRequest(
            apiBuilder: PersonAPIRequester.deletePerson(id: id)
        )
    }
    
}

extension PersonService {
    
    static func grantAdminRole(id: Int) async throws {
        try await NetworkService.sendRequest(
            apiBuilder: PersonAPIRequester.grantAdmin(id: id)
        )
    }
    
}

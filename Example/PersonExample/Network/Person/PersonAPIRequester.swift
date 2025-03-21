//
//  PersonAPIRequester.swift
//  NetworkBestPracticesSwiftUI
//
//  Created by Theo Sementa on 03/02/2025.
//

import Foundation
import NetworkKit

enum PersonAPIRequester: APIRequestBuilder {
    case fetchPersons
    case fetchPerson(id: Int)
    case createPerson(body: PersonModel)
    case updatePerson(id: Int, body: PersonModel)
    case deletePerson(id: Int)
    case grantAdmin(id: Int)
}

extension PersonAPIRequester {
    var path: String {
        switch self {
        case .fetchPersons, .createPerson:
            return NetworkPath.Person.persons
        case .fetchPerson(let id), .updatePerson(let id, _), .deletePerson(let id):
            return NetworkPath.Person.managePerson(id: id)
        case .grantAdmin(let id):
            return NetworkPath.Person.grantAdmin(id: id)
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .fetchPersons, .fetchPerson:   return .GET
        case .createPerson: return .POST
        case .updatePerson: return .PUT
        case .deletePerson: return .DELETE
        case .grantAdmin:   return .GET
        }
    }
    
    var parameters: [URLQueryItem]? {
        return nil
    }
    
    var isTokenNeeded: Bool {
        switch self {
        case .fetchPersons, .fetchPerson:
            return false
        case .createPerson, .updatePerson, .deletePerson, .grantAdmin:
            return true
        }
    }
        
    var body: Data? {
        switch self {
        case .createPerson(let body):
            return try? JSONEncoder().encode(body)
        case .updatePerson(_, let body):
            return try? JSONEncoder().encode(body)
        default:
            return nil
        }
    }
    
}

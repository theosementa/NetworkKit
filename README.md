# NetworkKit

- [Installation](#installation)
- [Usage](#usage)
  - [Defining API Endpoints](#defining-api-endpoints)
  - [Creating a Data Model](#creating-a-data-model)
  - [Implementing an API Requester](#implementing-an-api-requester)
  - [Building a Service Layer](#building-a-service-layer)
  - [Creating a Store for Caching](#creating-a-store-for-caching)

## Installation

To use this package, add it to your Swift Package Manager (SPM) dependencies and link it to your main app target.

```swift
https://github.com/theosementa/NetworkKit.git
```

## Usage

### Defining API Endpoints

Define all the API paths that will be used within your application inside the `NetworkPath.swift` file. This structure allows you to centralize and manage your API endpoints in a single location.

```swift
import Foundation

struct NetworkPath {
    static let baseURL: String = "https://my-domain.com"
    
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
```

### Creating a Data Model

Define the structure of the data models that will represent the API responses. These models should conform to `Codable` to facilitate encoding and decoding.

```swift
import Foundation

struct PersonModel: Codable, Identifiable {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var age: Int?
}
```

### Implementing an API Requester

To make API calls, create an `APIRequester` that defines the HTTP methods, endpoints, and request body structure. This component acts as an interface between your app and the API.

```swift
import Foundation
import NetworkKit

extension APIRequestBuilder {
    
    var headers: [(key: String, value: String)]? {
        var header = [(String, String)]()
        header.append(("Content-Type", "application/json"))
        if isTokenNeeded {
            header.append(("Authorization", "Bearer \(TokenManager.shared.token)"))
        }
        return header
    }
    
    var urlRequest: URLRequest? {
        let urlString = NetworkPath.baseURL + path

        var components = URLComponents(string: urlString)
        if let parameters {
            components?.queryItems = parameters
        }

        guard let url = components?.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        if let headers {
            headers.forEach {
                request.addValue($0.value, forHTTPHeaderField: $0.key)
            }
        }

        if let body {
            request.httpBody = body
        }

        return request
    }
    
}
```

```swift
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
```

### Building a Service Layer

Create a service that acts as a middle layer between the API requester and the rest of your application. This service will handle the actual API calls and return the processed data.

```swift
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
```

### Creating a Store for Caching

(This step is optional but recommended)

To avoid unnecessary API calls, you can create a store that caches data locally. This allows your application to use previously fetched data instead of requesting the same information multiple times.

```swift
@Observable
final class PersonStore {
    static let shared = PersonStore()
    
    var persons: [PersonModel] = []
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
```

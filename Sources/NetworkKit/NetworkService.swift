//
//  NetworkService.swift
//  NetworkKit
//
//  Created by Theo Sementa on 03/02/2025.
//

import Foundation

/// A protocol defining the necessary methods for a network service.
public protocol NetworkServiceProtocol {
    
    /// Sends a request and decodes the response.
    /// - Parameters:
    ///   - apiBuilder: An object that builds the API request.
    ///   - responseModel: The type of the response model to decode.
    /// - Returns: A decoded response of type `T`.
    /// - Throws: An error if the request or decoding fails.
    static func sendRequest<T: Decodable>(apiBuilder: APIRequestBuilder, responseModel: T.Type, retryWithConnection: Bool) async throws -> T

    /// Sends a request without expecting a response.
    /// - Parameters:
    ///   - apiBuilder: An object that builds the API request.
    /// - Throws: An error if the request fails.
    static func sendRequest(apiBuilder: APIRequestBuilder, retryWithConnection: Bool) async throws
    
    static func sendRequest(urlRequest: URLRequest, retryWithConnection: Bool) async throws
}

/// A class that provides network services and handles requests.
public struct NetworkService: NetworkServiceProtocol {
    
    static public func cancelAllTasks() {
        let session = URLSession.shared
        session.getAllTasks { tasks in
            tasks.forEach { task in
                task.cancel()
            }
        }
    }

    // MARK: - With Response

    /// Private method to send a request and decode the response.
    /// - Parameters:
    ///   - apiBuilder: An object that builds the API request.
    ///   - responseModel: The type of the response model to decode.
    /// - Returns: A decoded response of type `T`.
    /// - Throws: An error if the request or decoding fails.
    static public func sendRequest<T: Decodable>(
        apiBuilder: APIRequestBuilder,
        responseModel: T.Type,
        retryWithConnection: Bool = NetworkConfiguration.shared.isUrlRequestStoredByDefault
    ) async throws -> T {
        do {
            guard let urlRequest = apiBuilder.urlRequest else { throw NetworkError.badRequest }

            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            let networkReponse: NetworkResponse = .init(
                data: data,
                response: response,
                method: urlRequest.httpMethod
            )
            
            guard let dataToDecode = try mapResponse(response: networkReponse) else {
                throw NetworkError.parsingError
            }

            return try decodeResponse(dataToDecode: dataToDecode, responseModel: responseModel)
        } catch let error as NetworkError {
            if retryWithConnection && NetworkMonitor.shared.isConnected == false {
                guard let urlRequest = apiBuilder.urlRequest else { throw NetworkError.badRequest }
                
                let store = FileDeferredRequestStore()
                try store.enqueue(urlRequest)
            }
            
            throw error
        }
    }

    /// Decodes the response data to the specified model.
    /// - Parameters:
    ///   - dataToDecode: The data to decode.
    ///   - responseModel: The type of the response model to decode.
    /// - Returns: A decoded response of type `T`.
    /// - Throws: An error if decoding fails.
    static private func decodeResponse<T: Decodable>(dataToDecode: Data, responseModel: T.Type) throws -> T {
        do {
            let results = try JSONDecoder().decode(responseModel, from: dataToDecode)
            return results
        } catch {
            throw NetworkError.parsingError
        }
    }

    // MARK: - Without Response

    /// Private method to send a request without expecting a response.
    /// - Parameters:
    ///   - apiBuilder: An object that builds the API request.
    /// - Throws: An error if the request fails.
    static public func sendRequest(
        apiBuilder: APIRequestBuilder,
        retryWithConnection: Bool = NetworkConfiguration.shared.isUrlRequestStoredByDefault
    ) async throws {
        do {
            guard let urlRequest = apiBuilder.urlRequest else { throw NetworkError.badRequest }
            let (_, response) = try await URLSession.shared.data(for: urlRequest)
            let networkReponse: NetworkResponse = .init(
                response: response,
                method: urlRequest.httpMethod
            )

            _ = try mapResponse(response: networkReponse)
        } catch let error as NetworkError {
            if retryWithConnection && NetworkMonitor.shared.isConnected == false {
                guard let urlRequest = apiBuilder.urlRequest else { throw NetworkError.badRequest }
                
                let store = FileDeferredRequestStore()
                try store.enqueue(urlRequest)
            }
            
            throw error
        }
    }
    
    static public func sendRequest(
        urlRequest: URLRequest,
        retryWithConnection: Bool = NetworkConfiguration.shared.isUrlRequestStoredByDefault
    ) async throws {
        do {
            let (_, response) = try await URLSession.shared.data(for: urlRequest)
            let networkReponse: NetworkResponse = .init(
                response: response,
                method: urlRequest.httpMethod
            )

            _ = try mapResponse(response: networkReponse)
        } catch let error as NetworkError {
            if retryWithConnection && NetworkMonitor.shared.isConnected == false {
                let store = FileDeferredRequestStore()
                try store.enqueue(urlRequest)
            }
            
            throw error
        }
    }
    
}

public extension NetworkService {
    
    @concurrent
    func retryPendingRequests() async {
        let networkMonitor = NetworkMonitor.shared
        let store = FileDeferredRequestStore()
        
        guard networkMonitor.isConnected else { return }
        
        do {
            var requests = try store.load()
            requests.sort(by: { $0.createdAt < $1.createdAt })
            
            for request in requests {
                do {
                    try await Self.sendRequest(urlRequest: request.toUrlRequest())
                    try store.remove(request)
                } catch {
                    try store.remove(request)
                }
            }
        } catch {
            print("RetryManager error:", error)
        }
    }
    
}

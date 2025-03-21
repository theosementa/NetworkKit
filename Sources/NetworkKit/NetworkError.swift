//
//  NetworkError.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import Foundation

public enum NetworkError: Error, LocalizedError, CaseIterable {
    case notFound
    case unauthorized
    case badRequest
    case parsingError
    case conflict
    case fieldIsIncorrectlyFilled
    case internalError
    case refreshTokenFailed
    case noInternet
    case timeout
    case unknown
    case upgradeRequired

    public var errorDescription: String {
        switch self {
        case .notFound:                 return "Resource not found"
        case .unauthorized:             return "Unauthorized access"
        case .badRequest:               return "Bad request"
        case .parsingError:             return "Failed to parse the response"
        case .conflict:                 return "Conflict in the request"
        case .fieldIsIncorrectlyFilled: return "One or more fields are incorrectly filled"
        case .internalError:            return "Internal server error"
        case .refreshTokenFailed:       return "Failed to refresh the token"
        case .noInternet:               return "No internet connection"
        case .timeout:                  return "Request timed out"
        case .unknown:                  return "Unknown error"
        case .upgradeRequired:           return "Upgrade required"
        }
    }

    var statusCode: Int {
        switch self {
        case .notFound:                 return 404
        case .unauthorized:             return 401
        case .badRequest:               return 400
        case .parsingError:             return 422
        case .fieldIsIncorrectlyFilled: return 422
        case .conflict:                 return 409
        case .internalError:            return 500
        case .refreshTokenFailed:       return 401
        case .noInternet:               return 503
        case .timeout:                  return 408
        case .unknown:                  return 520
        case .upgradeRequired:          return 426
        }
    }
}

struct NetworkResponse {
    var data: Data?
    var response: URLResponse
    var method: String?
}

func processResponse(response: URLResponse, method: String?) throws -> HTTPURLResponse {
    guard let httpResponse = response as? HTTPURLResponse else {
        throw NetworkError.internalError
    }

    if let url = httpResponse.url {
        print("🛜 \(method ?? "") | \(httpResponse.statusCode) -> \(url)")
    }

    return httpResponse
}

func mapResponse(response: NetworkResponse) throws -> Data? {
    let httpResponse = try processResponse(response: response.response, method: response.method)
    return try handleStatusCode(httpResponse.statusCode, data: response.data)
}

func handleStatusCode(_ statusCode: Int, data: Data? = nil) throws -> Data? {
    if (200..<300).contains(statusCode) {
        return data
    }

    for case let error in NetworkError.allCases where error.statusCode == statusCode {
        throw error
    }

    throw NetworkError.unknown
}

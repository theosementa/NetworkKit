//
//  HTTPMethod.swift
//  NetworkKit
//
//  Created by Theo Sementa on 03/02/2025.
//

import Foundation

/// Represents the standard HTTP methods used in API requests.
public enum HTTPMethod: String {
    /// GET method for retrieving resources.
    case GET
    /// POST method for creating new resources.
    case POST
    /// PUT method for updating an existing resource.
    case PUT
    /// PATCH method for partially updating an existing resource.
    case PATCH
    /// DELETE method for removing a resource.
    case DELETE
}

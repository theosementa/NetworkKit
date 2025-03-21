//
//  PersonModel.swift
//  NetworkBestPracticesSwiftUI
//
//  Created by Theo Sementa on 03/02/2025.
//

import Foundation

struct PersonModel: Codable, Identifiable {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var age: Int?
}

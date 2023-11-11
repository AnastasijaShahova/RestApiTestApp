//
//  User.swift
//  ReqResApi
//
//  Created by Шахова Анастасия on 11.11.2023.
//

import Foundation

struct User: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let avatar: URL?
    
    init(id: Int, firstName: String, lastName: String, avatar: URL? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
    }
    
    init(postUserQUery: PostUserQuery) {
        self.id = 0
        self.firstName = postUserQUery.firstName
        self.lastName = postUserQUery.lastName
        self.avatar = nil
    }
    
}


struct UsersQuery: Decodable {
    let data: [User]
}

struct PostUserQuery: Codable {
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "name"
        case lastName = "job"
    }
}

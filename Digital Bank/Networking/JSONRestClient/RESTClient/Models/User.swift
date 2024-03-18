//
//  User.swift
//  RESTClient
//
//  Created by Alexander Gaidukov on 11/18/16.
//  Copyright © 2016 Alexander Gaidukov. All rights reserved.
//

import Foundation

//struct User: Decodable {
//    var id: String
//    var email: String
//    var name: String
//}
//
//struct FriendsResponse: Decodable {
//    var friends: [User]
//}

// MARK: - Users
struct UserResponseRoot:Decodable{
    let page: Int
    let per_page: Int
    let total: Int
    let total_pages: Int
    let data: [UserItem]
    let support: Support
}

// MARK: - Datum
struct UserItem : Decodable{
    let id: Int
    let email, first_name, last_name: String
    let avatar: String
}

// MARK: - Support
struct Support :Decodable {
    let url: String
    let text: String
}

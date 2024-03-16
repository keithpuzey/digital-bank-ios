//
//  SelectedUser.swift
//  Reqres App
//
//  Created by Girish Parate on 22/01/22.
//

import Foundation
class SelectedUserSingleton {
    
    static let selectedUserInfo = SelectedUserSingleton()
    var userData : UserListResponseData!
    private init() {
    }
}

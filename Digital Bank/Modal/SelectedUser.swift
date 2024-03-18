//
//  SelectedUser.swift
//  Digital Bank App
//
//  Created by Keith Puzey on 22/01/22.
//

import Foundation
class SelectedUserSingleton {
    
    static let selectedUserInfo = SelectedUserSingleton()
    var userData : UserListResponseData!
    private init() {
    }
}

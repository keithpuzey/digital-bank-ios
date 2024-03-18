//
//  ApiRepo.swift
//  RESTClient
//
//  Created by Apple on 10/08/21.
//  Copyright © 2021 Alexander Gaidukov. All rights reserved.
//

import Foundation
struct UserRepo {
   
    func getUserRepo(params: JSON) -> Resource<UserResponseRoot, CustomError> {
        let data = Resource<UserResponseRoot, CustomError>(jsonDecoder: JSONDecoder(), path: "/users",
            params: params)
        return data
    }
    
}

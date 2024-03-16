//
//  Helper.swift
//  UserList
//
//  Created by Girish Parate on 07/08/21.
//

import UIKit

extension UIImageView {
    
    func makeRounded() {
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true
    }
}

extension String {
    mutating func addString(str: String) {
        self = self + str
    }
}

extension UIBarButtonItem {
    convenience init(image :UIImage, title :String, target: Any?, action: Selector?) {
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.setTitle(title, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        if let target = target, let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        
        self.init(customView: button)
    }
}

struct UserFlow {
    private static func saveUserInMobile(isUserLogedIn:Bool) {
        let defaults = UserDefaults.standard
        defaults.set(isUserLogedIn, forKey: "isUserLogedIn")
    }
    
    static func saveLoginedInUser (isUserLogedIn:Bool){
        saveUserInMobile(isUserLogedIn: isUserLogedIn)
    }
}

struct ApiError {
    
    private static func CheckApiError(response: HTTPURLResponse?,data: Data?,self:UIViewController) -> Bool{
        if response?.statusCode == 200 {
            return true;
        } else {
            guard let errorData = try? JSONDecoder().decode(LoginResponseError.self, from: data! ) else {
                print("Error: Couldn't decode data into LoginResponseError")
                return false
            }
            AppToast().ShowToast(self: self, message: errorData.error ?? "Error")
            return false
        }
    }
    
    static func checkApiError(response: HTTPURLResponse?,data: Data?,self:UIViewController) -> Bool{
        return CheckApiError(response: response, data: data, self: self)
    }
}

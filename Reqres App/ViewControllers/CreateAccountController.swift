//
//  CreateAccountController.swift
//  Reqres App
//
//  Created by Girish Parate on 21/08/21.
//

import UIKit
import Alamofire

class CreateAccountController: UIViewController {
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func createAccount(_ sender: Any) {
        if(emailInput.text?.isEmpty ?? false && passwordInput.text?.isEmpty ?? false) {
            AppToast().ShowToast(self: self, message: "Please fill all the details")
        } else {
            let email : String = emailInput.text ?? ""
            let password :String = passwordInput.text ?? ""
            UserCreateAccountApi(email: email, password: password)
        }
    }
}


extension CreateAccountController {
    func UserCreateAccountApi(email : String,password : String) {
        let postdata: [String: Any] = [
            "email" : "eve.holt@reqres.in",
            "password":"cityslicka"
        ]
        AF.request("\(AppConst.baseurl)register",method: .post,parameters: postdata).validate().responseDecodable(of: RegisterResponse.self) { (response) in
            
            if ApiError.checkApiError(response: response.response!, data: response.data ?? nil, self: self) == true {
                guard let data = response.value else {
                    print(response)
                    print("Error")
                    return
                }
                AppToast().ShowToast(self: self, message: data.token!)
                let isUserLogedIn = true
                UserFlow.saveLoginedInUser(isUserLogedIn: isUserLogedIn)
                self.performSegue(withIdentifier: "SignUpToMainApp", sender: nil)
            }
        }
    }
}

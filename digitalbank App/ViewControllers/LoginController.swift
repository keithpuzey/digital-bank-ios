import UIKit
import Alamofire

class LoginController: UIViewController {
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onLoginPress(_ sender: Any) {
        guard let email = emailInput.text, !email.isEmpty else {
            showToast(message: "Please enter your email")
            return
        }
        
        guard let password = passwordInput.text, !password.isEmpty else {
            showToast(message: "Please enter your password")
            return
        }
        
        userLoginApi(email: email, password: password)
    }
    
    func userLoginApi(email: String, password: String) {
        let postData: [String: Any] = [
            "username": email,
            "password": password
        ]
        
        AF.request("http://dbankdemo.com/bank/api/v1/auth", method: .post, parameters: postData).validate().responseJSON { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case .success(let value):
                print("API Success: \(value)")
                
                if let json = value as? [String: Any], let token = json["authToken"] as? String {
                    self.showToast(message: token)
                    // Save logged-in user information
                   // UserFlow.saveLoggedInUser(isUserLoggedIn: true)
                    self.performSegue(withIdentifier: "toMainAppVC", sender: nil)
                } else {
                    print("Token not found in response")
                }
                
            case .failure(let error):
                print("API Error: \(error)")
                
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func showToast(message: String) {
        // Implement your toast functionality here
        print(message)
    }
}

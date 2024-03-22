import UIKit
import Alamofire

class LoginController: UIViewController {
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set default values for email and password
        emailInput.text = "jsmith@demo.io"
        passwordInput.text = "Demo123!"
        
    }
 
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    @IBAction func onLoginPress(_ sender: Any) {
        guard let email = emailInput.text, !email.isEmpty else {
            showToast(message: "Please enter your email")
            return
        }
        
        guard isValidEmail(email) else {
            showToast(message: "Please enter a valid email address")
            return
        }
        
        guard let password = passwordInput.text, !password.isEmpty else {
            showToast(message: "Please enter your password")
            return
        }
        // Store email in UserDefaults
        UserDefaults.standard.set(email, forKey: "loggedinuseremail")

        userLoginApi(email: email, password: password)
    }
    
    
    func userLoginApi(email: String, password: String) {
        let postData: [String: Any] = [
            "username": email,
            "password": password
        ]
        
        AF.request(AppConst.baseurl + "api/v1/auth", method: .post, parameters: postData).validate().responseJSON { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case .success(let value):
                print("API Success: \(value)")
                
                if let json = value as? [String: Any], let token = json["authToken"] as? String {
                    self.showToast(message: token)
                    UserDefaults.standard.set(token, forKey: "authToken")

                    
                    // Instantiate the UITabBarController
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBar") as? UITabBarController else {
                            return
                        }
                        // Present the UITabBarController
                        self.present(tabBarController, animated: true, completion: nil)
                    }
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

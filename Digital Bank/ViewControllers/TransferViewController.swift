import UIKit
import Alamofire

class TransferViewController: UIViewController {
    
    var authToken: String? // Token to be stored
    var userEmail: String?
    var userAccounts: [UserAccount] = []
    
    @IBOutlet weak var TransferDescription: UITextField!
    @IBOutlet weak var TransferAmount: UITextField!
    @IBOutlet weak var TransferAccountPicker: UIPickerView!

    @IBOutlet weak var TransactionTypeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let storedEmail = UserDefaults.standard.string(forKey: "loggedinuseremail") {
            print("Stored email: \(storedEmail)")
            userEmail = storedEmail
            
        } else {
            print("Email not found in UserDefaults")
        }
        
        TransferAccountPicker.delegate = self
        TransferAccountPicker.dataSource = self
        getUserList()
    }
    
 
    @IBAction func Logout(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)    }
    
    @IBAction func TransferSubmit(_ sender: UIButton) {
        // Check if there's a selected row
        let selectedRow = TransferAccountPicker.selectedRow(inComponent: 0)
        if selectedRow >= 0 && selectedRow < userAccounts.count {
            let selectedAccount = userAccounts[selectedRow]
            let transactionTypeCode = TransactionTypeSwitch.isOn ? "RFD" : "DBT"
            
            if let amountString = TransferAmount.text, let amount = Int(amountString) {
                let parameters: [String: Any] = [
                    "amount": amount,
                    "description": TransferDescription.text ?? "",
                    "transactionTypeCode": transactionTypeCode
                ]
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                    
                    let url = "\(AppConst.baseurl)api/v1/account/\(selectedAccount.accountId)/transaction"
                    
                    guard let token = authToken else {
                        print("Auth token not available")
                        return
                    }

                    let headers: HTTPHeaders = [
                        "Authorization": "Bearer \(token)",
                        "Content-Type": "application/json" // Specify JSON content type
                    ]
                    print("Request URL: \(url)")
                    print("Request Payload: \(parameters)")
                    print("Request Header: \(headers)")
                    AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
                        switch response.result {
                        case .success(let value):
                            print("Transaction Success: \(value)")
                            // Handle successful transaction
                            self.getUserList()

                        case .failure(let error):
                            print("Transaction Error: \(error)")
                            // Handle transaction failure
                        }
                    }
                    
                } catch {
                    print("Error encoding JSON: \(error)")
                }
            } else {
                print("Invalid amount entered")
                // Handle the case where the user entered an invalid amount
            }
        } else {
            print("Invalid selected account")
        }
    }


    
    struct UserAccount {
        let accountId: Int
        let name: String
        let accountNumber: Int
        let currentBalance: Double
        let openingBalance: Double
    }
    
    func loginAndFetchUserDetails() {
        let email = "admin@demo.io"
        let password = "Demo123!"
        
        let parameters: [String: Any] = [
            "username": email,
            "password": password
        ]
        
        AF.request(AppConst.baseurl + "api/v1/auth", method: .post, parameters: parameters).validate().responseJSON { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case .success(let value):
                print("API Success: \(value)")
                
                if let json = value as? [String: Any], let token = json["authToken"] as? String {
                    self.authToken = token // Store token for further use
                    self.fetchUserDetails(email: email, token: token)
                } else {
                    print("Token not found in response")
                }
                
            case .failure(let error):
                print("API Error: \(error)")
                // Handle API error
            }
        }
    }
    
    func fetchUserDetails(email: String, token: String) {
        guard let userEmail = userEmail else {
            print("User email is nil")
            return
        }
        
        let url = AppConst.baseurl + "api/v1/user/find?username=" + userEmail
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        AF.request(url, method: .get, headers: headers).validate().responseJSON { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case .success(let value):
                print("User Details Success: \(value)")
                
                if let json = value as? [String: Any],
                   let id = json["id"] as? Int {
                    print("ID from root object: \(id)")
                    
                    // Extract user profile from root object
                    if let userProfile = json["userProfile"] as? [String: Any],
                       let firstName = userProfile["firstName"] as? String,
                       let lastName = userProfile["lastName"] as? String,
                       let title = userProfile["title"] as? String {
                        // Display user details
                        print("First Name: \(firstName)")
                        print("Last Name: \(lastName)")
                        print("Title: \(title)")
                        
                        // Call fetchUserAccounts with token
                        self.fetchUserAccounts(userId: id, token: token)
                    } else {
                        print("User profile details not found or invalid in response")
                    }
                } else {
                    print("ID not found or invalid in response")
                }
            case .failure(let error):
                print("User Details Error: \(error)")
                // Handle user details fetch error
            }
        }
    }
    
    func getUserList() {
        // Perform login and fetch user details before fetching user list
        loginAndFetchUserDetails()
    }
    
    func fetchUserAccounts(userId: Int, token: String) {
        let url = AppConst.baseurl + "api/v1/user/\(userId)/account"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        AF.request(url, method: .get, headers: headers).validate().responseJSON { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case .success(let value):
                print("User Accounts Success: \(value)")
                
                if let jsonArray = value as? [[String: Any]] {
                    // Parse each user account
                    self.userAccounts.removeAll() // Clear existing user accounts
                    for json in jsonArray {
                        if let accountId = json["id"] as? Int,
                           let name = json["name"] as? String,
                           let accountNumber = json["accountNumber"] as? Int,
                           let currentBalance = json["currentBalance"] as? Double,
                           let openingBalance = json["openingBalance"] as? Double {
                            // Create a UserAccount object
                            let userAccount = UserAccount(accountId: accountId, name: name, accountNumber: accountNumber, currentBalance: currentBalance, openingBalance: openingBalance)
                            self.userAccounts.append(userAccount)
                        }
                    }
                    
                    // Reload the picker view data after fetching accounts
                    DispatchQueue.main.async {
                        self.TransferAccountPicker.reloadAllComponents()
                    }
                    print("User Accounts: \(self.userAccounts)")
                    
                } else {
                    print("User accounts not found in response or invalid format")
                }
                
            case .failure(let error):
                print("User Accounts Error: \(error)")
                // Handle user accounts fetch error
            }
        }
    }
}

extension TransferViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Assuming you only need one column in the picker view
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userAccounts.count // Number of rows should be equal to the number of accounts
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Display both account name and balance for each row
        let account = userAccounts[row]
        return "\(account.name) = \(account.currentBalance)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Perform the necessary action when a row is selected
        let selectedAccount = userAccounts[row]
        // Perform another query or action based on the selected account
        print("Selected account: \(selectedAccount)")
    }
}

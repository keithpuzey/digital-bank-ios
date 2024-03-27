//
//  DashboardViewController.swift
//  Digital Bank
//
//  Created by Keith Puzey on 3/22/24.
//

import UIKit
import Alamofire

// Define UserAccount struct
struct UserAccount {
    let accountId: Int
    let name: String
    let accountNumber: Int
    let currentBalance: Double
    let openingBalance: Double
}


class DashboardViewController: UIViewController {

    var authToken: String?
    var userEmail: String?
    var userAccounts: [UserAccount] = []
   
    @IBOutlet weak var UITableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let storedEmail = UserDefaults.standard.string(forKey: "loggedinuseremail") {
            print("Stored email: \(storedEmail)")
            userEmail = storedEmail
        } else {
            print("Email not found in UserDefaults")
        }
        UITableView.dataSource = self
        getUserList()
    }

    
    // MARK: - API Requests
    
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
                     self.UITableView.reloadData()
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

extension DashboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)
        
        let account = userAccounts[indexPath.row]
        cell.textLabel?.text = "Name: \(account.name)"
        cell.detailTextLabel?.text = "Balance: \(account.currentBalance)"
        cell.detailTextLabel?.text?.append ( "\nAccount Number: \(account.accountNumber)\nOpening Balance: \(account.openingBalance)")
        
        return cell
    }


}

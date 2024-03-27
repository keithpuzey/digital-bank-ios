
import UIKit
import Alamofire

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

       
 
    var authToken: String? // Token to be stored
    var userEmail: String?
    var userAccounts: [UserAccount] = []
    var transactions: [Transaction] = []
 
    @IBOutlet weak var LoggedInUser: UILabel!
    @IBOutlet weak var Accounts: UIPickerView!


    @IBOutlet weak var UITableView: UITableView!
    @IBOutlet weak var AccountSummary: UILabel!
    
    @IBOutlet weak var Logout: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        // Register custom cell class for the reuse identifier
   //     tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        
        if let storedEmail = UserDefaults.standard.string(forKey: "loggedinuseremail") {
            print("Stored email: \(storedEmail)")
            userEmail = storedEmail
            
        } else {
            print("Email not found in UserDefaults")
        }
               
        // Set up the picker view
        Accounts.delegate = self
        // Assign delegate to the correct outlet
        Accounts.dataSource = self
        // Assign data source to the correct outlet
        // Register TransactionCell class for "TransactionCell" reuse identifier
       // transactionsTableView.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
        // Set the data source and delegate of the table view
        UITableView.dataSource = self
        UITableView.delegate = self        // Set the data source for the table view
   //    transactionsTableView.dataSource = self
        getUserList()

    }
    


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserList()
    }


    struct UserAccount {
        let accountId: Int
        let name: String
        let accountNumber: Int
        let currentBalance: Double
        let openingBalance: Double
    }
    
    @IBAction func LogoutButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
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
                        // Display user details
                        print("First Name: \(firstName)")
                        print("Last Name: \(lastName)")
                        print("Title: \(title)")
                      //  self.LoggedInUser.text = " \(title) \(firstName) \(lastName)"
                        // Call fetchUserAccounts with token
                        self.fetchUserAccounts(userId: id, token: token)
                        
                        // Display user details on the screen
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            if let Welcome = self.LoggedInUser {
                                let welcomeMessage = " \(title) \(firstName) \(lastName)"
                                self.LoggedInUser.text = welcomeMessage
                                print("Welcome Message : \(welcomeMessage)")
                            } else {
                                print("Error: Welcome label is nil")
                            }
                        }
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
                    
                    print("User Accounts: \(self.userAccounts)")
                    
                    // Reload the picker view data after fetching accounts
                    DispatchQueue.main.async {
                        self.Accounts.reloadAllComponents()
                    }
                } else {
                    print("User accounts not found in response or invalid format")
                }
                
            case .failure(let error):
                print("User Accounts Error: \(error)")
                // Handle user accounts fetch error
            }
        }
    }

    // Fetch transactions for the selected account
    func fetchTransactions(for accountId: Int) {
        guard let token = authToken else {
            print("Authentication token not found")
            return
        }
        
        let url = "\(AppConst.baseurl)api/v1/account/\(accountId)/transaction"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        AF.request(url, method: .get, headers: headers).validate().responseJSON { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case .success(let value):
                print("Transactions Fetch Success: \(value)")
                
                if let jsonArray = value as? [[String: Any]] {
                    // Parse transaction data
                    self.transactions.removeAll()
                    for json in jsonArray {
                        if let transaction = Transaction(json: json) {
                            self.transactions.append(transaction)
                        }
                    }
                    
                    
                      // Print the contents of the transactions array
                      print("Transactions Array: \(self.transactions)")
                    // Update transactions table view
                    DispatchQueue.main.async {
                        self.UITableView.reloadData()
                    }
 
                } else {
                    print("Transactions not found in response or invalid format")
                }
                
            case .failure(let error):
                print("Transactions Fetch Error: \(error)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return transactions.count
     }
   

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell
        
        let transaction = transactions[indexPath.row]
        
        // Print transaction details for debugging
        print("Transaction Description: \(transaction.description)")
        print("Transaction Amount: \(transaction.amount)")
        print("Transaction Date: \(transaction.transactionDate)")
        print("Transaction Balance: \(transaction.runningBalance)")
        
        
         // Format the transaction date
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
         
         if let date = dateFormatter.date(from: transaction.transactionDate) {
             if Calendar.current.isDateInToday(date) {
                 // If the date is today, display "Today"
                 cell.dateLabel.text = "Today"
             } else {
                 // Otherwise, format the date normally
                 let newDateFormatter = DateFormatter()
                 newDateFormatter.dateFormat = "d MMMM yyyy" // Format: 1 April 2024
                 let formattedDate = newDateFormatter.string(from: date)
                 cell.dateLabel.text = formattedDate
             }
         } else {
             print("Failed to parse date: \(transaction.transactionDate)")
             cell.dateLabel.text = "N/A" // Handle case where date parsing fails
         }
        
        // Configure other cell labels
        cell.descriptionLabel.text = transaction.description
  
        cell.balanceLabel.text = "\(transaction.runningBalance)"
        // Configure amount label
        cell.amountLabel.text = "\(transaction.amount)"
        if transaction.amount < 0 {
            // If amount is negative, display in green
            cell.amountLabel.textColor = UIColor.green
        } else {
            // Otherwise, use default text color
            cell.amountLabel.textColor = UIColor.black
        }
        
        
        return cell
    }



 
}

extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        // Display user details on the screen
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let accountSummary = self.AccountSummary {
                accountSummary.numberOfLines = 0 // Allow multiple lines
                let summary = "Account =  \(selectedAccount.name) \n Account Number =  \(selectedAccount.accountNumber) \n Balance  = \(selectedAccount.currentBalance)"
                accountSummary.text = summary
                print("Selected Account : \(summary)")
                // Fetch transactions for the selected account
                self.fetchTransactions(for: selectedAccount.accountId)
            } else {
                print("Error: Account Summary Label is nil")
            }
        }
    }
    
    struct Transaction {
        let id: Int
        let description: String
        let amount: Double
        let runningBalance: Double
        let transactionDate: String
        
        init?(json: [String: Any]) {
            guard
                let id = json["id"] as? Int,
                let description = json["description"] as? String,
                let amount = json["amount"] as? Double,
                let runningBalance = json["runningBalance"] as? Double,
                let transactionDate = json["transactionDate"] as? String
            else {
                return nil
            }
            
            self.id = id
            self.description = description
            self.amount = amount
            self.runningBalance = runningBalance
            self.transactionDate = transactionDate
        }
    }

}

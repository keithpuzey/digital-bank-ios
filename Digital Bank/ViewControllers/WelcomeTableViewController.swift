import UIKit
import Alamofire


class WelcomeTableViewController: UITableViewController, UISearchResultsUpdating ,UISearchBarDelegate, UISearchControllerDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var welcomeLabel: UILabel!
    
    var userListData : UserListResponse!
    var orignalUserList : UserListResponse!
    var originalUserList: UserListResponse! // Add this line
    // For Search
    var resultSearchController = UISearchBar()
    let searchController = UISearchController()
    var searchText : String = ""
    var authToken: String? // Token to be stored
    var userEmail: String?
   

    // Toolbar buttons
    var myAccountsButton: UIBarButtonItem!
    var dashboardButton: UIBarButtonItem!
    var transferButton: UIBarButtonItem!
    var atmButton: UIBarButtonItem!
    @IBOutlet weak var welcome: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Welcome"
        navigationItem.leftBarButtonItem = nil
        self.tableView.dataSource = self
        self.tableView.delegate = self
        navigationController?.setNavigationBarHidden(false, animated: false)
        setUpSeachView()
        getUserList()
        welcome.text = "Test"
    }
    

    func setUpSeachView(){
        
        // Toolbar items with custom-sized icons and flexible space
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        if let myAccountsImage = UIImage(systemName: "tray.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30)) {
            myAccountsButton = UIBarButtonItem(image: myAccountsImage, style: .plain, target: self, action: #selector(myAccountsButtonTapped))
        }
        
        if let dashboardImage = UIImage(systemName: "chart.pie.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30)) {
            dashboardButton = UIBarButtonItem(image: dashboardImage, style: .plain, target: self, action: #selector(dashboardButtonTapped))
        }
        
        if let transferImage = UIImage(systemName: "dollarsign.square.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30)) {
            transferButton = UIBarButtonItem(image: transferImage, style: .plain, target: self, action: #selector(transferButtonTapped))
        }
        
        if let atmImage = UIImage(systemName: "map")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30)) {
            atmButton = UIBarButtonItem(image: atmImage, style: .plain, target: self, action: #selector(atmButtonTapped))
        }
        
        // Set toolbar items
        setToolbarItems([myAccountsButton, flexibleSpace, dashboardButton, flexibleSpace, transferButton, flexibleSpace, atmButton].compactMap { $0 }, animated: true)
        
        // Show toolbar
        navigationController?.isToolbarHidden = false
    }
    
    @objc func myAccountsButtonTapped() {
        let WelcomeTableViewController = WelcomeTableViewController()
        // Set left navigation button to nil to hide it
        navigationItem.leftBarButtonItem = nil
        navigationController?.pushViewController(WelcomeTableViewController, animated: false)
    }
    
    @objc func dashboardButtonTapped() {
        let DashBoardTableViewController = DashBoardTableViewController()
        // Set left navigation button to nil to hide it
        navigationItem.leftBarButtonItem = nil
        navigationController?.pushViewController(DashBoardTableViewController, animated: false)
    }
    
    @objc func transferButtonTapped() {
        let TransferTableViewController = TransferTableViewController()
        // Set left navigation button to nil to hide it
        navigationItem.leftBarButtonItem = nil
        navigationController?.pushViewController(TransferTableViewController, animated: false)
    }
    
    
    @objc func atmButtonTapped() {
        let ATMTableViewController = ATMTableViewController()
        // Set left navigation button to nil to hide it
        navigationItem.leftBarButtonItem = nil
        navigationController?.pushViewController(ATMTableViewController, animated: false)
    }
    
    // MARK: Search query
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text  else {
            userListData.data = orignalUserList.data
            self.tableView.reloadData()
            return;
        }
        if(text == ""){
            userListData.data = orignalUserList.data
            self.tableView.reloadData()
            return;
        }
        self.searchText = text
        let newArray = orignalUserList.data?.filter({ return $0.first_name?.contains(text) as! Bool })
        userListData.data = newArray
        self.tableView.reloadData()
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userListData?.data?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "FriendCell2", for: indexPath) as! UserListItemCell
        let item = userListData.data?[indexPath.row] ?? nil
        cell.setUserItemData(item: item!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.3,animations: {cell.alpha = 1}, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = userListData?.data?[indexPath.row]
        // Handle cell selection action here
    }
    
   

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.leftBarButtonItem = nil
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
                // Inside the fetchUserDetails method

                case .success(let value):
                    print("User Details Success: \(value)")
                    
                    if let json = value as? [String: Any], let userProfile = json["userProfile"] as? [String: Any] {
                        // Extract user details
                        if let firstName = userProfile["firstName"] as? String,
                           let lastName = userProfile["lastName"] as? String,
                           let title = userProfile["title"] as? String,
                           let id = userProfile["id"] as? Int {
                            // Display user details
                            print("First Name: \(firstName)")
                            print("Last Name: \(lastName)")
                            print("Title: \(title)")
                            print("ID: \(id)")
                            
                            // Display user details on the screen
                       //     DispatchQueue.main.async {
                                // Assuming you have labels for displaying user details
                         //       let welcomeMessage = "Welcome \(title) \(firstName) \(lastName)"

                                // Assuming you have a label named welcomeLabel
                           //     self.welcome.text = welcomeMessage
                             //   print(welcomeMessage)
                         //   }
                        }
                    } else {
                        print("User details not found in response")
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
}

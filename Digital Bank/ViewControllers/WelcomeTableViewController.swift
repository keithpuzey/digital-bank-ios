import UIKit
import Alamofire

class WelcomeTableViewController: UITableViewController, UISearchResultsUpdating ,UISearchBarDelegate, UISearchControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    var userListData : UserListResponse!
    var orignalUserList : UserListResponse!
    // For Search
    var resultSearchController = UISearchBar()
    let searchController = UISearchController()
    var searchText : String = ""
    
    // Toolbar buttons
    var myAccountsButton: UIBarButtonItem!
    var dashboardButton: UIBarButtonItem!
    var transferButton: UIBarButtonItem!
    var atmButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Welcome"
        self.tableView.dataSource = self
        self.tableView.delegate = self
        setUpSeachView()
        getUserList()
    }
    
    
    func setUpSeachView(){
        // Search View
        searchController.searchResultsUpdater = self;
        resultSearchController.delegate = self
        resultSearchController.showsScopeBar = true
        searchController.searchBar.delegate = self
        searchController.automaticallyShowsSearchResultsController = false
        searchController.showsSearchResultsController = false
        searchController.delegate = self
        searchController.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        // Toolbar items with custom-sized icons and flexible space
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        if let myAccountsImage = UIImage(systemName: "person")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30)) {
            myAccountsButton = UIBarButtonItem(image: myAccountsImage, style: .plain, target: self, action: #selector(myAccountsButtonTapped))
        }
        
        if let dashboardImage = UIImage(systemName: "chart.pie")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30)) {
            dashboardButton = UIBarButtonItem(image: dashboardImage, style: .plain, target: self, action: #selector(dashboardButtonTapped))
        }
        
        if let transferImage = UIImage(systemName: "arrow.up.arrow.down")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30)) {
            transferButton = UIBarButtonItem(image: transferImage, style: .plain, target: self, action: #selector(transferButtonTapped))
        }
        
        if let atmImage = UIImage(systemName: "creditcard")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30)) {
            atmButton = UIBarButtonItem(image: atmImage, style: .plain, target: self, action: #selector(atmButtonTapped))
        }
        
        // Set toolbar items
        setToolbarItems([myAccountsButton, flexibleSpace, dashboardButton, flexibleSpace, transferButton, flexibleSpace, atmButton].compactMap { $0 }, animated: true)
        
        // Show toolbar
        navigationController?.isToolbarHidden = false
    }
    
    @objc func myAccountsButtonTapped() {
        // Handle my accounts button tap
    }
    
    @objc func dashboardButtonTapped() {
        // Handle dashboard button tap
    }
    
    @objc func transferButtonTapped() {
        // Handle transfer button tap
    }
    
    @objc func atmButtonTapped() {
        // Handle ATM button tap
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
    
    // MARK: - API Requests
    
    func getUserList() {
        let parameters: [String: Any] = [
            "page":"1",
            "per_page":"55"
        ]
        AF.request(AppConst.baseurl+AppConst.usersListUrl,method: .get,parameters: parameters).validate().responseDecodable(of: UserListResponse.self) { [self] (response) in
            guard let data = response.value else {
                print(response)
                print("Error")
                return
            }
            self.userListData = data
            self.orignalUserList = data
            self.tableView.reloadData()
        }
    }
}


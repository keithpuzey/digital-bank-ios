//
//  WelcomeTableViewController.swift
//  Reqres App
//
//  Created by Girish Parate on 05/02/22.
//

import UIKit
import Alamofire

class WelcomeTableViewController: UITableViewController, UISearchResultsUpdating ,UISearchBarDelegate, UISearchControllerDelegate,UICollectionViewDelegateFlowLayout{

    var userListData : UserListResponse!
    var orignalUserList : UserListResponse!
    // For Search
    var resultSearchController = UISearchBar()
    let searchController = UISearchController()
    var searchText : String = ""
    
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
    }
    
    //On Search Enter
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Do Search API Here!")
    }
    //On remove search View
    func didDismissSearchController(_ searchController: UISearchController) {
        // When Search is removed
        print("Search is removed")
    }
    
    @IBAction func logOutTaped(_ sender: Any) {
        // Delete Local Storage
        deleteUser()
    }
    
    func deleteUser(){
        let alert = UIAlertController(title: "Logout?", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil ))
        alert.addAction(UIAlertAction(title: "Okay",style: .destructive,handler: logOutUser))
        DispatchQueue.main.async { self.present(alert, animated: true) }
    }
    
    func logOutUser(alert: UIAlertAction!)  {
        let isUserLogedIn = false
        UserFlow.saveLoginedInUser(isUserLogedIn: isUserLogedIn)
        performSegue(withIdentifier: "MainAppToAuthVC", sender: nil)
    }
    
    func goToInfo(item:UserListResponseData) {
        // Save UserObj in Class
        SelectedUserSingleton.selectedUserInfo.userData = item
        performSegue(withIdentifier: "goToUserInfo", sender: nil)
    }
    @objc func goBack(){
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
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
        self.goToInfo(item: item!)
    }
}


extension WelcomeTableViewController {
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



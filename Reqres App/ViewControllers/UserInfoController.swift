//
//  UserInfoController.swift
//  Reqres App
//
//  Created by Girish Parate on 21/08/21.
//

import UIKit

class UserInfoController: UIViewController {

    var userId : String = "";
    @IBOutlet weak var userInfoImage: UIImageView!
    var userListItem: UserListResponseData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userListItem =  SelectedUserSingleton.selectedUserInfo.userData
        userInfoImage.makeRounded()
        userInfoImage.sd_setImage(with: URL(string: userListItem?.avatar ?? ""))
        title = userListItem?.first_name
    }
}

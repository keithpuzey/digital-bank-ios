//
//  UserListItemCell.swift
//  UserList
//
//  Created by Girish Parate on 07/08/21.
//

import UIKit
import SDWebImage

class UserListItemCell: UITableViewCell {
    
    @IBOutlet weak var userImageItem: UIImageView!
    @IBOutlet weak var userNameItem: UILabel!
    @IBOutlet weak var userEmailItem: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageItem.makeRounded()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setUserItemData(item : UserListResponseData) {
        userNameItem.text = item.first_name
        userEmailItem.text = item.email
        userImageItem.sd_setImage(with: URL(string: item.avatar!))
    }

}

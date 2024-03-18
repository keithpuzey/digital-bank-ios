//
//  AppToast.swift
//  Digital Bank App
//
//  Created by Keith Puzey on 21/08/21.
//

import Foundation
import UIKit
import Toast_Swift

struct AppToast {
    func ShowToast(self:UIViewController,message:String) {
        self.view.makeToast(message)
    }
}

//
//  UserManager.swift
//  MapPoints
//
//  Created by Artem on 27.12.2019.
//  Copyright © 2019 Artem. All rights reserved.
//

import UIKit
import Firebase

class UserManager: NSObject {
    
    static let shared: UserManager = UserManager()
    
    var name: String?
    var photoUrl: String?
    var photoImg: UIImage?
    
    var apiToken: String?
    
    private override init() {
        super.init()
        restorePreviousSignIn()
    }

    var isAuthorized: Bool {
        get {
//            if let instance = GIDSignIn.sharedInstance(), instance.hasPreviousSignIn() == true {
//                // User authorized before
//                return true
//            } else {
//                // User not authorized open sign in screen
                return false
//            }
        }
    }
    
    func restorePreviousSignIn() {
//        UserManager.shared.profileRestoring = true
        
    }
    
    func googleSignOut() {
        
    }
    
}

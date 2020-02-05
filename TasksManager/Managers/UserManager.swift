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
    
    var email: String?
    var apiToken: String? {
        didSet {
            saveSignIn()
        }
    }
    
    private override init() {
        super.init()
        restorePreviousSignIn()
    }

    lazy var isAuthorized: Bool = {
        return apiToken != nil
    }()
        
    
    func restorePreviousSignIn() {
        let userDefaults = UserDefaults.standard
        email = userDefaults.string(forKey: "email")
        apiToken = userDefaults.string(forKey: "apiToken")
    }
    
    func saveSignIn() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(email, forKey: "email")
        userDefaults.set(apiToken, forKey: "apiToken")
        userDefaults.synchronize()
    }
    
}

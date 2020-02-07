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
    
    fileprivate let kTokenUpdateTime = "tokenUpdateTime"
    fileprivate let kEmail = "email"
    fileprivate let kPassword = "password"
    
    static let shared: UserManager = UserManager()
    
    var email: String?
    private var tokenUpdateTime: Date?
    var apiToken: String? {
        didSet {
            tokenUpdateTime = Date()
            saveSignIn()
        }
    }
    
    
    private override init() {
        super.init()
        restorePreviousSignIn()
    }

    var isAuthorized: Bool {
        get {
            return apiToken != nil && isTokenValid()
        }
    }
        
    
    func restorePreviousSignIn() {
        let userDefaults = UserDefaults.standard
        email = userDefaults.string(forKey: kEmail)
        apiToken = userDefaults.string(forKey: kPassword)
        tokenUpdateTime = userDefaults.value(forKey: kTokenUpdateTime) as? Date
    }
    
    func saveSignIn() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(email, forKey: kEmail)
        userDefaults.set(apiToken, forKey: kPassword)
        userDefaults.set(tokenUpdateTime, forKey: kTokenUpdateTime)
        userDefaults.synchronize()
    }
    
    func removeSignIn() {
        UserDefaults.standard.removeObject(forKey: kEmail)
        UserDefaults.standard.removeObject(forKey: kPassword)
        UserDefaults.standard.removeObject(forKey: kTokenUpdateTime)
        UserDefaults.standard.synchronize()
        
        email = nil
        apiToken = nil
        tokenUpdateTime = nil
    }
    
    func isTokenValid() -> Bool {
        guard let `tokenUpdateTime` = tokenUpdateTime else { return false }
        if let diff = Calendar.current.dateComponents([.hour], from: tokenUpdateTime, to: Date()).hour, diff >= 24 {
            return false
        }
        return true
    }
    
}

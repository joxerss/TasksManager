//
//  AppDelegate+Extensions.swift
//  MapPoints
//
//  Created by Artem on 27.12.2019.
//  Copyright © 2019 Artem. All rights reserved.
//

import Foundation
import Firebase

extension AppDelegate {
    
    func configurateFirebase() {
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
    }
    
    // MARK: - Managers
    
    func startManagers() {
        _ = InternetConnectionManager.shared
    }
    
}

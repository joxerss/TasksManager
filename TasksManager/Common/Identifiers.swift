//
//  Identifiers.swift
//  MapPoints
//
//  Created by Artem on 27.12.2019.
//  Copyright © 2019 Artem. All rights reserved.
//

import UIKit

let animationCheckDone = "checked-done"
let animationLoadingGoogle = "loading-google"
let animationSearchEmpty = "search-empty"

extension UIStoryboard {
    // MARK: - storyboard identities
    static public let modal = "Modal"
    static public let main = "Main"
}

extension UINavigationController {
    // MARK: - Main storyboard navigation identities
    static public let signInNavigationController = "SignInNavigationController"
    static public let tasksNavigationController = "TasksNavigationController"
}

extension UITabBarController {
    
}

extension UIViewController {
    // MARK: - Main storyboard controllers identities
    static public let signInViewController = "SignInViewController"
    static public let tasksViewController = "TasksViewController"
    
    // MARK: - Modal storyboard controllers identities
    static public let modalConnectionViewController = "InternetConnection"
}

extension UINib {
    // MARK: - Nib names
    
    // MARK: - Nib reuse identifiers

}

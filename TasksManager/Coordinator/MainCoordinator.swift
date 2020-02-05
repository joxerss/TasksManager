//
//  MainCoordinator.swift
//  MapPoints
//
//  Created by Artem on 27.12.2019.
//  Copyright © 2019 Artem. All rights reserved.
//

import UIKit

extension UIViewController {
    static func initContoller(_ storyboard: String, identifier: String) -> UIViewController {
        let storyboard = UIStoryboard.init(name: storyboard, bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: identifier)
        
        return controller
    }
}

class MainCoordinator: NSObject {

    static let shared: MainCoordinator = MainCoordinator()
    
    private override init() {
        super.init()
    }
    
    func setRootViewController(_ viewController: UIViewController, complition: (()->())? ) -> Void {
        var window: UIWindow? = nil
        if #available(iOS 13.0, *) {
            // iOS 13 (or newer) Swift code
            window = UIApplication.shared.windows.first
        } else {
            // iOS older code
            window = UIApplication.shared.keyWindow
        }
        
        guard let curWindow = window else {
            fatalError("🚀❌ window can't be nil!!")
        }
        
        viewController.modalPresentationStyle = .fullScreen
        curWindow.rootViewController = viewController
        curWindow.makeKeyAndVisible()
        
        UIView.transition(with: curWindow, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: { _ in
            if let complition = complition {
                complition()
            }
        })
    }
    
    func generateWindow(windowScene: UIWindowScene) -> UIWindow {
        
        // Validate on Controller here
        let contentController: UIViewController!
        if (UserManager.shared.isAuthorized) {
            contentController = UIViewController.initContoller(UIStoryboard.main, identifier: UINavigationController.tasksNavigationController)
        } else {
            contentController = UIViewController.initContoller(UIStoryboard.main, identifier: UINavigationController.signInNavigationController)
        }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = contentController
        window.makeKeyAndVisible()
        return window
    }
    
    func SignIn() {
        // API SIGN IN
        if UserManager.shared.isAuthorized {
            navigateToTasksController()
        }
    }
    
    func SignOut() {
        // API SIGN OUT
        if !UserManager.shared.isAuthorized {
            navigateToSignInController()
        }
    }
    
    private func navigateToSignInController() {
        setRootViewController(UIViewController.initContoller(UIStoryboard.main, identifier: UINavigationController.signInNavigationController), complition: nil)
    }
    
    private func navigateToTasksController() {
        setRootViewController(UIViewController.initContoller(UIStoryboard.main, identifier: UINavigationController.tasksNavigationController), complition: nil)
    }
    
//    func presentCrationPoint(in controller: UIViewController, point: CLLocationCoordinate2D) {
//        let contentController = UIViewController.initContoller(UIStoryboard.main, identifier: UIViewController.creationPointViewController) as! CreationPointViewController
//        contentController.loadViewIfNeeded()
//
//        contentController.modalPresentationStyle = .custom
//        contentController.modalTransitionStyle = .crossDissolve
//
//        contentController.point = point
//        controller.present(contentController, animated: true, completion: nil)
//
//    }
    
}

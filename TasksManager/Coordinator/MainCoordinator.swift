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
    var rootController: UIViewController!
    
    // MARK: - Life cycle
    
    private override init() {
        super.init()
    }
    
    // MARK: - Global actions
    
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

        rootController = viewController
        
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
        rootController = contentController
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
    
    // MARK: - Private
    
    private func navigateToSignInController() {
        setRootViewController(UIViewController.initContoller(UIStoryboard.main, identifier: UINavigationController.signInNavigationController), complition: nil)
    }
    
    private func navigateToTasksController() {
        setRootViewController(UIViewController.initContoller(UIStoryboard.main, identifier: UINavigationController.tasksNavigationController), complition: nil)
    }
    
    // MARK: - Public present / push controllers
    
    public func navigateToTaskDetailsController(_ task: Task, completionChange: @escaping TaskChangeCompletion) {
       let contentController = UIViewController.initContoller(UIStoryboard.main, identifier: UIViewController.taskDetailsViewController) as! TaskDetailsViewController
        contentController.loadViewIfNeeded()
        
        contentController.modalPresentationStyle = .custom
        contentController.modalTransitionStyle = .crossDissolve
        
        contentController.fillWith(task, creationCompletion: completionChange)
        
        if let `rootController` = rootController {
            Material.getVisibleViewController(rootController)?.navigationController?.pushViewController(contentController, animated: true)
        }
    }
    
    public func presentCreateChangeTaskDetailsController(_ task: Task?, completionChange: @escaping TaskChangeCompletion) {
       let contentController = UIViewController.initContoller(UIStoryboard.main, identifier: UINavigationController.taskChangeNavigationController) as! UINavigationController
        contentController.loadViewIfNeeded()
        
        contentController.modalPresentationStyle = .automatic
        contentController.modalTransitionStyle = .coverVertical
        
        if let taskController = contentController.viewControllers.first as? TaskChangeViewController {
            taskController.loadViewIfNeeded()
            taskController.fillWith(task, creationCompletion: completionChange)
        }
        
        if let `rootController` = rootController {
            Material.getVisibleViewController(rootController)?.present(contentController, animated: true, completion: nil)
        }
    }
    
    public func presentCalendarViewController(_ date: Date?, selectionDateCompletion: @escaping CalendarSelectCompletion) {
        let contentController = UIViewController.initContoller(UIStoryboard.modal, identifier: UIViewController.fsCalendarViewController) as! FSCalendarViewController
        contentController.loadViewIfNeeded()
        
        contentController.modalPresentationStyle = .automatic
        contentController.modalTransitionStyle = .coverVertical
        
        contentController.selectedDate = date
        contentController.callBackReturnDate = selectionDateCompletion
        
        if let `rootController` = rootController {
            Material.getVisibleViewController(rootController)?.present(contentController, animated: true, completion: nil)
        }
    }
    
}

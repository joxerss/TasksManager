//
//  UITableView+Extensions.swift
//  TasksManager
//
//  Created by Artem Syritsa on 04.02.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import UIKit

extension UITableView {
    
    public typealias PullToRefreshCompletion = ()->()
    
    // MARK: - Properties
    private struct AssociatedKeys {
        static var kPullToRefreshControl = "key_pullToRefreshControl"
        static var kPullToRefreshCompletion = "key_pullToRefreshCompletion"
    }
    
    // MARK: - Associated Keys
    private var pullToRefreshControl: UIRefreshControl {
        get {
            guard let view = objc_getAssociatedObject(self, &AssociatedKeys.kPullToRefreshControl) as? UIRefreshControl else {
                return initRefreshControl()
            }
            
            return view
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.kPullToRefreshControl, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var pullToRefreshCompletion: PullToRefreshCompletion? {
        get {
            guard let completion = objc_getAssociatedObject(self, &AssociatedKeys.kPullToRefreshCompletion) as? PullToRefreshCompletion else {
                return nil
            }
            
            return completion
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.kPullToRefreshCompletion, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    // MARK: - Init's
    
    private func initRefreshControl() -> UIRefreshControl {
        let refreshControl: UIRefreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        self.addSubview(refreshControl) // not required when using UITableViewController
        
        self.pullToRefreshControl = refreshControl
        
        return refreshControl
    }
    
    // MARK: - Actions
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        guard let completion = self.pullToRefreshCompletion else { return }
        completion()
    }
    
    // MARK: - Public functions
    
    public func setupPullToRefresh(completion: PullToRefreshCompletion?) {
        _ = pullToRefreshControl
        self.pullToRefreshCompletion = completion
    }
    
    public func endPullToRefresh() {
        pullToRefreshControl.endRefreshing()
    }
}

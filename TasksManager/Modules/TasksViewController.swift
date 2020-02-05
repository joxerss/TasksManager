//
//  TasksViewController.swift
//  TasksManager
//
//  Created by Artem Syritsa on 04.02.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import UIKit

class TasksViewController: BaseController {

    @IBOutlet weak var tableView: UITableView!
    
    var listOfTasks: Array<Task> = Array<Task>()
    
    /// Current page
    var current: Int = 1
    
    /// Total pages
    var limit: Int = 1
    
    /// Count tasks on page
    let count: Int = 14
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Overrides
    
    override func prepareViews() {
        reloadFromServer()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.setupPullToRefresh (completion: { [weak self] in
            self?.pullToRefreshAction()
        })
        showAnimatedDone()
    }
    

    // MARK: - Reload
    
    func reloadFromServer() {
        self.showAnimatedLoader()
        RequestManager.shared.tasksList(page: current) { [weak self] list in
            print("")
            DispatchQueue.main.async { [weak self] in
                self?.hideAnimatedLoader()
                self?.tableView.reloadData()
            }
        }
    }
    
    func pullToRefreshAction() -> Void {
        RequestManager.shared.tasksList(page: current) { [weak self] list in
            print("")
            DispatchQueue.main.async { [weak self] in
                self?.tableView.endPullToRefresh()
                self?.tableView.reloadData()
            }
        }
        
    }

}

// MARK: - TableViewDelegate & DataSource
extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listOfTasks.count == 0 ? showAnimatedSearchEmpty() : hideAnimatedSearchEmpty()
        return listOfTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}

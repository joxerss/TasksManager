//
//  TasksViewController.swift
//  TasksManager
//
//  Created by Artem Syritsa on 04.02.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import UIKit
import MaterialComponents.MDCButton

class TasksViewController: BaseController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var floatingButton: MDCFloatingButton!
    
    var listOfTasks: Array<Task> = Array<Task>()
    
    /// Page for pagination
    var current: Int = 0
    
    /// Total pages
    var limit: Int = 0
    
    var canPaginate: Bool = false
    var sortBy: SortBy = .asc
    
    lazy var taskCreateCompletion: TaskChangeCompletion = {
        return { [weak self] task in
            guard let `self` = self else {
                fatalError("❌taskCreateChangeCompletion, self nil!")
            }
            
            self.listOfTasks.removeAll(where: { $0.id == task.id })
            self.listOfTasks.insert(task, at: 0)
            DispatchQueue.main.async {  [weak self] in
                self?.tableView.reloadData()
            }
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Overrides
    
    override func prepareViews() {
        reloadFromServer()
        
        tableView.register(UINib(nibName: TaskTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: TaskTableViewCell.nibIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.setupPullToRefresh (completion: { [weak self] in
            self?.pullToRefreshAction()
        })
        showAnimatedDone()
    }
    
    override func setupAppearances() {
        floatingButton.setTitle(nil, for: .normal)
        floatingButton.setBackgroundColor(.buttonColor)
        floatingButton.setImage(#imageLiteral(resourceName: "list_add"), for: .normal)
        floatingButton.tintColor = .white
    }
    

    // MARK: - Reload
    
    func reloadFromServer() {
        self.showAnimatedLoader()
        RequestManager.shared.tasksList(page: current, sort: sortBy) { [weak self] listJson in
            self?.parseJson(json: listJson)
            DispatchQueue.main.async { [weak self] in
                self?.hideAnimatedLoader()
                self?.tableView.reloadData()
            }
        }
    }
    
    func pullToRefreshAction() -> Void {
        current = 0
        limit = 0
        canPaginate = false
        
        RequestManager.shared.tasksList(page: current, sort: sortBy) { [weak self] listJson in
            self?.parseJson(json: listJson)
            DispatchQueue.main.async { [weak self] in
                self?.tableView.endPullToRefresh()
                self?.tableView.reloadData()
            }
        }
        
    }
    
    // MARK: - Prepare Json
    
    func parseJson(json: Dictionary<String, Any>?) {
        let meta: Dictionary<String, Any>? = json?["meta"] as? Dictionary<String, Any>
        let count = meta?["count"] as? Int ?? 0
        limit = meta?["limit"] as? Int ?? 0
        
        debugPrint("⚡️ tasks fetched: \(count)")
        
        canPaginate = count > 0 && count <= limit ? true : false
        
        if(count == 0) {
            canPaginate = false
            return
        } else {
            canPaginate = true
        }
        
        let list: Array<Dictionary<String, Any>>? = json?["tasks"] as? Array<Dictionary<String, Any>>
        list?.forEach({ (jsonTask) in
            listOfTasks.append(Task.init(jsonTask))
        })
    }
    
    @IBAction func floatButtonAction(_ sender: MDCFloatingButton) {
//        MainCoordinator.shared.navigateToTaskDetailsController(Task(Dictionary<String, Any>()))
        MainCoordinator.shared.presentCreateChangeTaskDetailsController(nil, completionChange: taskCreateCompletion)
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
        let cell: TaskTableViewCell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.nibIdentifier, for: indexPath) as! TaskTableViewCell
        cell.fillWith(listOfTasks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        displayDetails(task: listOfTasks[indexPath.row])
    }
    
    func displayDetails(task: Task) {
        guard let `id` = task.id else { return  }
        
        self.showAnimatedLoader()
        RequestManager.shared.detailsTask(taskId: id) { [weak self] (json, _) in
            DispatchQueue.main.async {  [weak self] in
                self?.hideAnimatedLoader()
            }
            guard let `json` = json,
                let `self` = self else { return }
            
            let updatedTask = Task(json)
            DispatchQueue.main.async {  [weak self] in
                guard let `self` = self else { return }
                MainCoordinator.shared.navigateToTaskDetailsController(updatedTask, completionChange: self.taskCreateCompletion)
            }
        }
    }

}

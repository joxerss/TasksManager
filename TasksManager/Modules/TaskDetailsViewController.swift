//
//  TaskDetailsViewController.swift
//  TasksManager
//
//  Created by Artem Syritsa on 06.02.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import UIKit

class TaskDetailsViewController: BaseController {
    
    var taskCreateChangeCompletion: TaskChangeCompletion?
    var task: Task!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var priorityValue: UILabel!
    @IBOutlet weak var priorityImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupAppearances() {
        titleLabel.textColor = .lightGray
        priorityLabel.textColor = .lightGray
        dateLabel.textColor = .lightGray
    }
    
    override func prepareNavigationBar() {
        let saveBarButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editBarButtonAction(_:)))
        
        self.navigationItem.rightBarButtonItem = saveBarButton
    }
    
    override func localize() {
        self.priorityLabel.text = "common.priority".localized()
    }
    

    // MARK: - Fill
    
    func fillWith(_ task: Task, creationCompletion: @escaping TaskChangeCompletion) {
        self.taskCreateChangeCompletion = creationCompletion
        self.task = task
        updatePriorityIcon()
        
        self.titleLabel.text = task.title
        self.dateLabel.text = task.dueBy?.convertToDate().convertToString("")
        self.priorityValue.text = task.priority.rawValue
    }
    
    func updatePriorityIcon() {
        
        priorityImage.image = nil
        
        switch task.priority {
        case .Low:
            priorityImage.image = #imageLiteral(resourceName: "arrow_down")
        case .Normal:
            priorityImage.image = #imageLiteral(resourceName: "arrow_right")
        case .High:
            priorityImage.image = #imageLiteral(resourceName: "arrow_up")
        }
    }
    
    // MARK: -  Actions

    @objc func editBarButtonAction(_ sender: UITabBarItem) {
        guard let `taskCreateChangeCompletion` = taskCreateChangeCompletion else {
            return
        }
        
        MainCoordinator.shared.presentCreateChangeTaskDetailsController(task) { [weak self] (task) in
            guard let `self` = self else { return }
            self.fillWith(task, creationCompletion: taskCreateChangeCompletion)
            taskCreateChangeCompletion(task)
        }
    }

}

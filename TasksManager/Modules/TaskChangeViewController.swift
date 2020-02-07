//
//  TaskChangeViewController.swift
//  TasksManager
//
//  Created by Artem Syritsa on 06.02.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import UIKit

typealias TaskChangeCompletion = (_ changedTask: Task)->()
//typealias TaskCreateCompletion = (_ createdTask: Task)->()

class TaskChangeViewController: BaseController {

    @IBOutlet weak var keyboardConstraint: UIScrollView!
    var taskCreateChangeCompletion: TaskChangeCompletion?
    var task: Task!
    
    var controllerMode: TaskChangeCreateMode = .createMode
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var lowButton: UIButton!
    @IBOutlet weak var normalButton: UIButton!
    @IBOutlet weak var hightButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Overrides
    
    override func prepareViews() {
        hideKeyboardOnTap()
        self.titleTextView.delegate = self
        self.descriptionTextView.delegate = self
    }
    
    override func setupAppearances() {
        titleTextView.backgroundColor = .clear
        titleTextView.layer.cornerRadius = 5
        titleTextView.layer.borderWidth = 1.0
        titleTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        lowButton.backgroundColor = .buttonColor
        normalButton.backgroundColor = .buttonColor
        hightButton.backgroundColor = .buttonColor
        
        lowButton.setTitleColor(.white, for: .normal)
        normalButton.setTitleColor(.white, for: .normal)
        hightButton.setTitleColor(.white, for: .normal)
        
        titleLabel.textColor = .lightGray
        priorityLabel.textColor = .lightGray
        notificationLabel.textColor = .lightGray
    }
    
    override func localize() {
        titleLabel.text = "common.title".localized()
        priorityLabel.text = "common.priority".localized()
        notificationLabel.text = "common.select_date".localized()
    }
    
    override func prepareNavigationBar() {
        let saveBarButton: UIBarButtonItem = UIBarButtonItem.init(title: "common.save".localized(), style: .plain, target: self, action: #selector(saveBarButtonAction(_:)))
        
        self.navigationItem.rightBarButtonItem = saveBarButton
    }
    
    override func setupObservers() {
        observeKeyboard()
    }
    
    override func removeObservers() {
        unobserveKeyboard()
    }
    
    // MARK: - Fill
    
    func fillWith(_ task: Task?, creationCompletion: @escaping TaskChangeCompletion) {
        self.taskCreateChangeCompletion = creationCompletion
        self.controllerMode = task != nil ? .changeMode : .createMode
        
        self.task = task != nil ? task : Task()
        self.updateSelectedPriority()
        self.titleTextView.text = task?.title
        let timeTitle = task?.dueBy?.convertToDate().convertToString()
        self.timeButton.setTitle(timeTitle != nil ? timeTitle : "common.select_date".localized(), for: .normal)
    }
    
    func updateSelectedPriority() {
        
        lowButton.backgroundColor = .buttonColor
        normalButton.backgroundColor = .buttonColor
        hightButton.backgroundColor = .buttonColor
        
        switch task.priority {
        case .Low:
            lowButton.backgroundColor = .buttonSelectedColor
        case .Normal:
            normalButton.backgroundColor = .buttonSelectedColor
        case .High:
            hightButton.backgroundColor = .buttonSelectedColor
        }
    }
    

    // MARK: -  Actions

    @objc func saveBarButtonAction(_ sender: UITabBarItem) {
        guard let `task` = task else {
            fatalError("❌ Task can't be nil")
        }
        
        if task.title == nil {
            Material.showMaterialAlert(title: "common.alert".localized(), message: "common.enter_title".localized())
            return
        }
        
        if task.dueBy == nil {
            Material.showMaterialAlert(title: "common.alert".localized(), message: "common.enter_due".localized())
            return
        }
        
        if controllerMode == .createMode {
            self.showAnimatedLoader()
            RequestManager.shared.createTask(json: task.convertToJson(), { [weak self] (json, _) in
                DispatchQueue.main.async {  [weak self] in
                    self?.hideAnimatedLoader()
                }
                
                guard let `json` = json else {
                    return
                }
                self?.task = Task(json)
                self?.taskCreateChangeCompletion?((self?.task)!)
                DispatchQueue.main.async {  [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
            })
        } else if controllerMode == .changeMode {
            guard let taskId = task.id else {
                fatalError("❌ Task ID can't be nil")
            }
            self.showAnimatedLoader()
            RequestManager.shared.updateTask(taskId: taskId, json: task.convertToJson(), { [weak self] (isSuccess) in
                DispatchQueue.main.async {  [weak self] in
                    self?.hideAnimatedLoader()
                }
                
                if isSuccess {
                    self?.taskCreateChangeCompletion?((self?.task)!)
                    DispatchQueue.main.async {  [weak self] in
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            })
        }
    }
    
    @IBAction func lowPriorityAction(_ sender: Any) {
        task?.priority = .Low
        updateSelectedPriority()
    }
    
    @IBAction func normalPriorityAction(_ sender: Any) {
        task?.priority = .Normal
        updateSelectedPriority()
    }
    
    @IBAction func hightPriorityAction(_ sender: Any) {
        task?.priority = .High
        updateSelectedPriority()
    }
    
    @IBAction func timeButtonAction(_ sender: Any) {
        MainCoordinator.shared.presentCalendarViewController(task?.dueBy?.convertToDate()) { [weak self] (date, stringDate) in
            self?.task.dueBy = date.convertToTimeSpan()
            self?.timeButton.setTitle(stringDate, for: .normal)
        }
    }
    
    
}

// MARK: - Extensions
extension TaskChangeViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.setTextViewHeight(textView)
        if textView == titleTextView {
            task?.title = titleTextView.text
        }
    }
    
    func setTextViewHeight(_ textView: UITextView) {
        let size = textView.contentSize//CGSize(width: view.frame.width, height: .infinity)
        textView.sizeThatFits(size)
        if size.height >= 100 {
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
            textView.setNeedsUpdateConstraints()
        }
    }
}

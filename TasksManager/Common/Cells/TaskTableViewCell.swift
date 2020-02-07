//
//  TaskTableViewCell.swift
//  TasksManager
//
//  Created by Artem Syritsa on 07.02.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    static let nibName = "TaskTableViewCell"
    static let nibIdentifier = "TaskTableViewCell"

    @IBOutlet weak var titleTask: UILabel!
    @IBOutlet weak var dateTask: UILabel!
    @IBOutlet weak var priorityTask: UILabel!
    @IBOutlet weak var priorityImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleTask.text = nil
        self.priorityTask.text = nil
        self.dateTask.text = nil
        self.priorityImage.image = nil
    }
    
    func fillWith(_ task: Task) -> Void {
        self.titleTask.text = task.title
        self.priorityTask.text = task.priority.rawValue
        self.updatePriorityIcon(priority: task.priority)
        
        if let due = task.dueBy {
            let time = due.convertToDate()
            self.dateTask.text = "\("due.to".localized()) \(time.convertToString())"
        } else {
            self.dateTask.text = "\("due.to".localized()) unoun"
        }
    }
    
    func updatePriorityIcon(priority: TaskPriority) {
        
        priorityImage.image = nil
        
        switch priority {
        case .Low:
            priorityImage.image = #imageLiteral(resourceName: "arrow_down")
        case .Normal:
            priorityImage.image = #imageLiteral(resourceName: "arrow_right")
        case .High:
            priorityImage.image = #imageLiteral(resourceName: "arrow_up")
        }
    }
    
}

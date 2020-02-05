//
//  Task.swift
//  TasksManager
//
//  Created by Artem Syritsa on 05.02.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import UIKit

class Task: NSObject {
    
    var id: Int?
    var title: String?
    var dueBy: Float?
    var priority: TaskPriority?
    
    init(_ json: Dictionary<String, Any>) {
        id = json["id"] as? Int
        title = json["title"] as? String
        dueBy = json["dueBy"] as? Float
        priority = json["priority"] as? TaskPriority
    }
    
}

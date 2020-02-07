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
    var dueBy: Int?
    var priority: TaskPriority
    
    override init() {
        id = nil
        title = nil
        dueBy = nil
        priority = .Normal
    }
    
    init(_ json: Dictionary<String, Any>) {
        id = json["id"] as? Int
        title = json["title"] as? String
        dueBy = json["dueBy"] as? Int
        let priorityString = json["priority"] as? String
        priority =  TaskPriority(rawValue: priorityString ?? TaskPriority.Normal.rawValue)!
    }
    
    func convertToJson() -> Dictionary<String, Any> {
        return [
          "title": title ?? "",
          "dueBy": dueBy ?? "",
          "priority": priority.rawValue
        ]
    }
    
}

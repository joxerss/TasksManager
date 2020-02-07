//
//  Enums.swift
//  TasksManager
//
//  Created by Artem Syritsa on 05.02.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import Foundation

enum RequesType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum SortBy: String {
    case asc = "title asc"
    case desc = "title desc"
}

enum TaskPriority: String {
   case Low = "Low"
   case Normal = "Normal"
   case High = "High"
}

enum TaskChangeCreateMode {
    case createMode
    case changeMode
}

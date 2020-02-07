//
//  ConvertExtensions.swift
//  TasksManager
//
//  Created by Artem Syritsa on 07.02.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import Foundation

extension Int {
    
    func convertToDate() -> Date {
        let myTimeInterval = TimeInterval(self)
        let time: Date = Date(timeIntervalSince1970: TimeInterval(myTimeInterval))
        return time
    }
    
}

extension Date {
    
    func convertToString(_ format: String = "yyyy/MM/dd") -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    func convertToTimeSpan() -> Int {
        Int(self.timeIntervalSince1970)
    }
    
}

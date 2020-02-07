//
//  RequestManager+Tasks.swift
//  TasksManager
//
//  Created by Artem Syritsa on 07.02.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import Foundation

extension RequestManager {
    
    fileprivate static let kToken = "token"
    fileprivate static let kTask = "task"
    
    func signUp(_ email: String, _ password: String, _ completion: @escaping RequestResultSignIn) {
        let url = "/users" // Post
        let json = [
            "email": email,
            "password": password
        ]
        
        makeRequest(apiMethod: url, requestType: .post, parameters: json, completion: { jsonResult, isSuccess  in
            guard let `jsonResult` = jsonResult as? Dictionary<String, Any> else {
                completion(nil)
                return
            }
            let token = jsonResult[RequestManager.kToken] as? String
            completion(token)
        })
    }
    
    func signIn(_ email: String, _ password: String, _ completion: @escaping RequestResultSignIn) {
        let url = "/auth" // Post
        let json = [
            "email": email,
            "password": password
        ]
        
        makeRequest(apiMethod: url, requestType: .post, parameters: json, completion: { jsonResult, isSuccess in
            guard let `jsonResult` = jsonResult as? Dictionary<String, Any> else {
                completion(nil)
                return
            }
            let token = jsonResult[RequestManager.kToken] as? String
            completion(token)
        })
    }
    
    func tasksList(page: Int, sort: SortBy = .asc, _ completion: @escaping RequestResultTaskList) {
        let url = "/tasks" // Get
        let json: [String: Any] = [
            "page": page,
            "sort": sort.rawValue
        ]
        makeRequest(apiMethod: url, requestType: .get, parameters: json, completion: { jsonResult, isSuccess in
            guard let `jsonResult` = jsonResult as? Dictionary<String, Any> else {
                completion(nil)
                return
            }
            completion(jsonResult)
        })
    }

    func createTask(json: Dictionary<String, Any>, _ completion: @escaping RequestResultTask) {
        let url = "/tasks" // Post
        
        makeRequest(apiMethod: url, requestType: .post, parameters: json, completion: { jsonResult, isSuccess in
            guard let `jsonResult` = jsonResult as? Dictionary<String, Any>,
                let task = jsonResult[RequestManager.kTask] as? Dictionary<String, Any> else {
                completion(nil, isSuccess)
                return
            }
            completion(task, isSuccess)
        })
    }

    func detailsTask(taskId: Int, _ completion: @escaping RequestResultTask) {
        let url = "/tasks/\(taskId)" // Get
        
        makeRequest(apiMethod: url, requestType: .get, parameters: nil, completion: { jsonResult, isSuccess in
            guard let `jsonResult` = jsonResult as? Dictionary<String, Any>,
                let task = jsonResult[RequestManager.kTask] as? Dictionary<String, Any> else {
                completion(nil, isSuccess)
                return
            }
            completion(task, isSuccess)
        })
    }

    func updateTask(taskId: Int, json: Dictionary<String, Any>, _ completion: @escaping RequestResultIsSuccess) {
        let url = "/tasks/\(taskId)" // Put
        
        makeRequest(apiMethod: url, requestType: .put, parameters: json, completion: { _, isSuccess in
            completion(isSuccess)
        })
    }

    func deleteTask(taskId: Int, _ completion: @escaping RequestResultTask) {
        let url = "/tasks/\(taskId)" // Delete
        
        makeRequest(apiMethod: url, requestType: .delete, parameters: nil, completion: { jsonResult, isSuccess in
            guard let `jsonResult` = jsonResult as? Dictionary<String, Any>,
                let task = jsonResult[RequestManager.kTask] as? Dictionary<String, Any> else {
                completion(nil, isSuccess)
                return
            }
            completion(task, isSuccess)
        })
    }
    
}

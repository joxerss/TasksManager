//
//  RequestManager.swift
//  TasksManager
//
//  Created by Artem Syritsa on 04.02.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import UIKit

typealias RequestResult = (Any?, _ isSuccess: Bool)->()
typealias RequestResultIsSuccess = (_ isSuccess: Bool)->()
typealias RequestResultSignIn = (_ token: String?)->()
typealias RequestResultTaskList = (_ list: Dictionary<String, Any>?)->()
typealias RequestResultTask = (_ list: Dictionary<String, Any>?, _ isSuccess: Bool)->()

class RequestManager: NSObject {

    static let shared: RequestManager = RequestManager()
    
    static let baseUrl: String = "https://testapi.doitserver.in.ua/api"
    
    private override init() {
        super.init()
    }
    
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
            let token = jsonResult["token"] as? String
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
            let token = jsonResult["token"] as? String
            completion(token)
        })
    }
    
    func tasksList(page: Int, sort: SortBy = .asc, _ completion: @escaping RequestResultTaskList) {
        let url = "/tasks" // Get
        let json: [String: Any] = [
            "page": page,
            "sort": sort.rawValue/*,
            "offset": "0",
            "limit": "15",*/
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
                let task = jsonResult["task"] as? Dictionary<String, Any> else {
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
                let task = jsonResult["task"] as? Dictionary<String, Any> else {
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
                let task = jsonResult["task"] as? Dictionary<String, Any> else {
                completion(nil, isSuccess)
                return
            }
            completion(task, isSuccess)
        })
    }
    
    // MARK: - Private
    
    private func makeRequest(apiMethod: String, requestType: RequesType,
                             parameters: Dictionary<String, Any>?, completion: @escaping RequestResult) {
        let url = URL(string: "\(RequestManager.baseUrl)\(apiMethod)")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(UserManager.shared.apiToken ?? "")", forHTTPHeaderField: "Authorization")
        request.httpMethod = requestType.rawValue
        
        if requestType == .get {
            var queryParams = ""
            parameters?.keys.forEach({ (key) in
                queryParams = queryParams.count == 0 ? "?\(key)=\(parameters?[key] ?? "")" : "\(queryParams)&\(key)=\(parameters?[key] ?? "")"
            })
            request.url = URL(string: "\(url.absoluteString)\(queryParams)")
        } else {
            if let `parameters` = parameters {
                do {
                    try request.httpBody = JSONSerialization.data(withJSONObject: parameters, options: [])
                } catch {
                    completion(nil, false)
                    return
                }
            }
        }
        

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    Material.showSnackBar(message: error?.localizedDescription ?? "Unknown error", duration: 8.0)
                    completion(nil, false)
                    return
            }

            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                self.errorHandler(response: response, data: data)
                completion(nil, false)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                completion(json, true)
            } catch {
                completion(nil, true)
            }
        }

        task.resume()
    }
    
    func errorHandler(response: HTTPURLResponse, data: Data) {
        var json: Dictionary<String, Any>?
        do {
            json = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any>
        } catch { }
        
        if (300 ... 421) ~= response.statusCode && json != nil {
            
            let message: String = json?["message"] as? String ?? "json?[\"message\"]"
            Material.showSnackBar(message: message, duration: 5.0)
            
        }  else if (422 ... 503) ~= response.statusCode && json != nil {
            
            guard  let title: String = json?["message"] as? String,
                let fields: Dictionary<String, Any> = json?["fields"] as? Dictionary<String, Any> else {
                    let message: String = json?["message"] as? String ?? "Response code:\(response.statusCode)"
                    Material.showSnackBar(message: message, duration: 5.0)
                    return
            }
            
            var message: String = ""
            fields.keys.forEach { (key) in
                if let array = fields[key] as? Array<String> {
                    array.forEach { (msg) in
                        message = "\(message)\n\(msg)"
                    }
                } else {
                    message = "\(message)\n\(fields[key] ?? "none")"
                }
            }
            
            DispatchQueue.main.async {
                Material.showMaterialAlert(title: title, message: message)
            }
            
        } else {
            Material.showSnackBar(message: "Response code:\(response.statusCode)", duration: 5.0)
        }
    }
    
}

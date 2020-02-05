//
//  RequestManager.swift
//  TasksManager
//
//  Created by Artem Syritsa on 04.02.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import UIKit

typealias RequestResult = (Any?)->()
typealias RequestResultSignIn = (_ token: String?)->()
typealias RequestResultTaskList = (_ list: Array<Dictionary<String, Any>>?)->()

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
        
        makeRequest(apiMethod: url, requestType: .post, parameters: json, completion: { jsonResult in
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
        
        makeRequest(apiMethod: url, requestType: .post, parameters: json, completion: { jsonResult in
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
            "sort": sort.rawValue
        ]
        makeRequest(apiMethod: url, requestType: .get, parameters: json, completion: { jsonResult in
            guard let `jsonResult` = jsonResult as? Array<Dictionary<String, Any>> else {
                completion(nil)
                return
            }
            completion(jsonResult)
        })
    }

    func createTask() {
        let url = "/tasks" // Post
    }

    func detailsTask() {
        let url = "/tasks/{task}" // Get
    }

    func updateTask() {
        let url = "/tasks/{task}" // Put
    }

    func deleteTask() {
        let url = "/tasks/{task}" // Delete
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
//        request.httpBody = parameters?.percentEncoded()
        
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
                    completion(nil)
                    return
                }
            }
        }
        

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    Material.showSnackBar(message: error?.localizedDescription ?? "Unknown error", duration: 8.0)
                    completion(nil)
                    return
            }

            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                self.errorHandler(response: response, data: data)
                completion(nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                completion(json)
            } catch {
                completion(nil)
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

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

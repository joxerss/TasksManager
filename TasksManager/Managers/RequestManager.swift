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
    
    // MARK: - Public
    
    func makeRequest(apiMethod: String, requestType: RequesType,
                             parameters: Dictionary<String, Any>?, completion: @escaping RequestResult) {
        let url = URL(string: "\(RequestManager.baseUrl)\(apiMethod)")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(UserManager.shared.apiToken ?? "")", forHTTPHeaderField: "Authorization")
        request.httpMethod = requestType.rawValue
        
        if requestType == .get {
            var components = URLComponents(string: url.absoluteString)!
            components.queryItems = parameters?.map({ (arg0) -> URLQueryItem in
                let (key, value) = arg0
                return URLQueryItem(name: key, value: value as? String ?? "")
            })
            request.url = components.url
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

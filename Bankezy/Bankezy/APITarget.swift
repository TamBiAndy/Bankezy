//
//  APITarget.swift
//  Bankezy
//
//  Created by Andy on 26/11/2024.
//

import UIKit
import Moya

enum APITarget: TargetType {
    
    case creatAcc(email: String, password: String, phone: String)
    case login(email: String, password: String, autoLogin: Bool)
    
    var baseURL: URL {
        return URL(string: "")!
    }
    
    var path: String {
        switch self {
        case .creatAcc:
           return "/creatAcc"
        case .login:
            return "/login"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .creatAcc, .login:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .creatAcc(let email, let password, let phone):
            return .requestParameters(parameters: ["email": email,
                                                   "password": password,
                                                   "phone": phone], encoding: JSONEncoding.default)
        case .login(let email, let password, let autoLogin):
            return .requestParameters(parameters: ["email": email,
                                                   "password": password,
                                                   "autoLogin": autoLogin], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return [ "Authorization": "Bearer \(SessionManager.shared.token)"]
    }
    
    var sampleData: Data {
        let fileName = self.path.components(separatedBy: "/").last!
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
                    let data = try? Data(contentsOf: url) else {
                        return Data()
                }
        return data
    }
}

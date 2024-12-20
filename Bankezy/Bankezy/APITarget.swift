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
    case getCategory
    case getBestpartner
    case getPartnerNearby
    case getPartnerSales
    case getPartnerRating
    case getPartnerFast
    case getPartnerAll
    case searchPartner
    case brandDetail(brandDetail: String?)
    case popularItemsOfBrand
    case getMenuOfBrand
    case getReviewBrand
    
    var baseURL: URL {
        return URL(string: "https://f3fb93b6-d607-4da3-abeb-2312a3ab8bff.mock.pstmn.io")!
    }
    
    var path: String {
        switch self {
        case .creatAcc:
           return "/creatAcc"
        case .login:
            return "/login"
        case .getCategory:
            return "/category"
        case .getBestpartner:
            return "/bestPartners"
        case .getPartnerNearby:
            return "/bestPartners/nearby"
        case .getPartnerSales:
            return "/bestPartners/sales"
        case .getPartnerRating:
            return "/bestPartners/rate"
        case .getPartnerFast:
            return "/bestPartners/fast"
        case .getPartnerAll:
            return "/bestPartner/seeAllPartner"
        case .searchPartner:
            return "/searchPartner"
        case .brandDetail:
            return "/brandDetail"
        case .popularItemsOfBrand:
            return "/popularItems"
        case .getMenuOfBrand:
            return "/menu"
        case .getReviewBrand:
            return "/reviewBrand"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .creatAcc, .login:
            return .post
        case .getCategory, .getBestpartner, .getPartnerFast, .getPartnerSales, .getPartnerNearby, .getPartnerRating, .getPartnerAll, .searchPartner, .brandDetail, .popularItemsOfBrand, .getMenuOfBrand, .getReviewBrand:
            return .get
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
        case .getCategory, .getBestpartner, .getPartnerFast, .getPartnerSales, .getPartnerNearby, .getPartnerRating, .getPartnerAll, .searchPartner, .brandDetail, .popularItemsOfBrand, .getMenuOfBrand, .getReviewBrand:
            return .requestParameters(parameters: [:], encoding: URLEncoding.default)
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

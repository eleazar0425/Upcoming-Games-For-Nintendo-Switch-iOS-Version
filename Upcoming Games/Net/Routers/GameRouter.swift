//
//  GameRouter.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/17/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import Foundation
import Alamofire

enum GameRouter : URLRequestConvertible {
    
    case getGamesOfAmerica()
    
    static let baseURL = "https://nintendoswitchgames.herokuapp.com"
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        switch self {
        case .getGamesOfAmerica():
            return "/gamesAmerica"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try GameRouter.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        return urlRequest
    }
}

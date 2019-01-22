//
//  IGDBRouter.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella GB on 1/22/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import Foundation
import Alamofire

enum IGDBRouter: URLRequestConvertible {

    case getGameDescription(game: Game)
    
    static let baseURL = "https://api-v3.igdb.com/search"
    static let API_KEY = "e3a72db62a26551bcef80c4faa633274"
    
    var method: HTTPMethod {
        return .post
    }
    
    var body: String {
        switch self{
        case .getGameDescription(let game):
            return "fields game.summary; search \"\(game.title)\";"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try IGDBRouter.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        urlRequest.httpBody = self.body.data(using: .utf8, allowLossyConversion: false)
        urlRequest.setValue(IGDBRouter.API_KEY, forHTTPHeaderField: "user-key")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return urlRequest
    }
}

//
//  YoutubeRouter.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella GB on 1/22/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//
import Foundation
import Alamofire

enum YoutubeRouter : URLRequestConvertible {
    
    case getGameTrailer(game: Game)
    
    static let baseURL = "https://www.googleapis.com/youtube/v3/search"
    static let API_KEY = "AIzaSyCeUK73oZEue7wQ9tAeGt1G5WXElqmYvbE"
    
    var method: HTTPMethod {
        return .get
    }
    
    var params: Parameters {
        switch self {
        case .getGameTrailer(let game):
            return [
                "key": YoutubeRouter.API_KEY,
                "part": "id, snippet",
                "maxResults": 1,
                "type": "video",
                "q": "\(game.title) for nintendo switch trailer"
            ]
        }
    }
    
    
    func asURLRequest() throws -> URLRequest {
        let url = try YoutubeRouter.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        urlRequest = try URLEncoding.default.encode(urlRequest, with: self.params)
        
        return urlRequest
    }
}

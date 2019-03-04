//
//  YoutubeService.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella GB on 1/22/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import Foundation
import SwiftyJSON

class YoutubeService {
    private let client: Client
    
    typealias CompletionHandler = (_ videoId: String?, _ thumbnail: String?, _ error: ServiceError? ) -> Void
    
    required init(client: Client) {
        self.client = client
    }

    func getGameTrailer(game: Game, completion: @escaping CompletionHandler){
        let route = YoutubeRouter.getGameTrailer(game: game)
        client.request(route) { (data, serviceError) in
            guard let id = data?["items"][0]["id"]["videoId"].stringValue,
                let thumbnail = data?["items"][0]["snippet"]["thumbnails"]["high"]["url"].stringValue else {
                return completion(nil, nil, ServiceError.noDataAvailable())
            }
            completion(id, thumbnail, serviceError)
        }
    }
}

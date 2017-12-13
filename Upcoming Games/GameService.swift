//
//  GameService.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/17/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import Foundation
import SwiftyJSON

class GameService {
    private let client: Client
    
    typealias CompletionHandler = (_ games: [Game]?, _ error: ServiceError? ) -> Void
    
    required init(client: Client) {
        self.client = client
    }
    
    func getGames(completion: @escaping CompletionHandler){
        let route = GameRouter.getGamesOfAmerica()
        client.request(route) { (data, serviceError) in
            guard let games = data?.arrayValue.flatMap(Game.init) else {
                return completion(nil, ServiceError.noDataAvailable())
            }
            print(games)
            print(serviceError)
            completion(games, serviceError)
        }
    }
}

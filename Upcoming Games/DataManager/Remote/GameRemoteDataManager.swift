//
//  GameRemoteDataManager.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/17/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import Foundation

class GameRemoteDataManager {
    typealias CompletionHanlder = (_ games: [Game]?, _ error: ServiceError?) -> Void
    
    let service: GameService
    
    required init(service: GameService) {
        self.service = service
    }
    
    func getGames(completion: @escaping CompletionHanlder){
        service.getGames(completion: completion)
    }
}

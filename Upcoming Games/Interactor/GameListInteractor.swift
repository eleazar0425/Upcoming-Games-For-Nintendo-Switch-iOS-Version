//
//  GameInteractor.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/17/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import Foundation

class GameListInteractor {
    
    typealias Completion = (_ games: [Game]?, _ error: Error?) -> Void
    
    var localDataManager: GameLocalDataManager!
    var remoteDataManager: GameRemoteDataManager!
    
    func getGames(completion: @escaping Completion){
        guard Reachability.isConnectedToNetwork() else {
            guard let games = localDataManager?.getGames() else { return completion(nil, ServiceError.noDataAvailable()) }
            
            guard !games.isEmpty else {
                return completion(games, ServiceError.noDataAvailable())
            }
            
            return completion(games, nil)
        }
        
        remoteDataManager.getGames(completion: { (games, error) in
            if let gamesResult = games {
                self.saveGames(games: gamesResult)
            }
            
            if error == nil {
                return completion(games, error)
            }
            
            let games = self.localDataManager?.getGames()
            completion(games, nil)
            
        })
    }
    
    
    fileprivate func saveGames(games: [Game]){
        localDataManager.saveGames(games: games)
    }
    
    func saveFavorite(_ id: String){
        localDataManager.saveFavorite(favorite: Favorite(id))
    }
    
    func deleteFavorite(_ id: String){
        localDataManager.deleteFavorite(favorite: Favorite(id))
    }
    
    func isFavorite(_ id: String) -> Bool {
        return localDataManager.isFavorite(favorite: Favorite(id))
    }
}

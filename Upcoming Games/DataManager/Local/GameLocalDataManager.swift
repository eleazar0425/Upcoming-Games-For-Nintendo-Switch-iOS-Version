//
//  GameLocalDataManager.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/17/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import Foundation
import RealmSwift

class GameLocalDataManager {
    
    var realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
    }
    
    func getGames() -> [Game]? {
        let result = realm.objects(Game.self)
        guard result.count != 0 else {
            return []
        }
        
        var games = [Game]()
        
        for i in 0..<result.count {
            games.append(result[i])
        }
        
        return games
    }
     
    func saveGames(games: [Game]){
        try! realm.write {
            //By now just rewrite all data
            realm.delete(realm.objects(Game.self))
            for game in games {
                realm.add(Game.clone(game: game))
            }
        }
    }
    
    func saveFavorite(favorite: Favorite){
        try! realm.write {
            realm.add(favorite, update: true)
        }
    }
    
    func deleteFavorite(favorite: Favorite){
        try! realm.write {
            guard let objectToDelete = realm.object(ofType: Favorite.self, forPrimaryKey: favorite.id) else {return}
            realm.delete(objectToDelete)
        }
    }
    
    func isFavorite(favorite: Favorite) -> Bool {
        let result = realm.object(ofType: Favorite.self, forPrimaryKey: favorite.id)
        guard let _ = result else { return false }
        return true
    }
    
    func getFavorites() -> [Favorite]? {
        let result = realm.objects(Favorite.self)
        guard result.count != 0 else {
            return []
        }
        
        var favorites = [Favorite]()
        
        for i in 0..<result.count {
            favorites.append(result[i])
        }
        
        return favorites
    }
    
    func saveSuscription(suscription: Suscription) {
        try! realm.write {
            realm.add(suscription, update: true)
        }
    }
    
    func deleteSuscription(suscription: Suscription){
        try! realm.write {
            guard let objectToDelete = realm.object(ofType: Suscription.self, forPrimaryKey: suscription.id) else {return}
            realm.delete(objectToDelete)
        }
    }
    
    func isSuscribed(suscription: Suscription) -> Bool {
        let result = realm.object(ofType: Suscription.self, forPrimaryKey: suscription.id)
        guard let _ = result else { return false }
        return true
    }
    
    func getDiscountedFavoritesGames() -> [Game]? {
        let result = realm.objects(Game.self)
        guard result.count != 0 else {
            return []
        }
        
        var games = [Game]()
        
        for i in 0..<result.count {
            games.append(result[i])
        }
        
        return games.filter { game in
            game.salePrice != "" && isFavorite(favorite: Favorite(game.id))
        }
    }
}

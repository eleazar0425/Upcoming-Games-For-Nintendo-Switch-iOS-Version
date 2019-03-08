//
//  GameLocalDataManager.swift
//  Switch Library Widget
//
//  Created by Eleazar Estrella GB on 3/8/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import Foundation
import RealmSwift

class GameLocalDataManager {
    
    var realm: Realm
    
    init() {
        let fileURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.switchlibrary")!
            .appendingPathComponent("default.realm")
        let config = Realm.Configuration(fileURL: fileURL, deleteRealmIfMigrationNeeded: true)
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        self.realm = try! Realm()
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
    
    func isFavorite(favorite: Favorite) -> Bool {
        let result = realm.object(ofType: Favorite.self, forPrimaryKey: favorite.id)
        print(result ?? "no favorite value")
        print(realm.objects(Favorite.self))
        guard let _ = result else { return false }
        return true
    }
}


//
//  FavoriteEvent.swift
//  Switch Library
//
//  Created by Eleazar Estrella GB on 1/25/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import Foundation

class FavoriteEvent {
    var game: Game
    var isFavorite: Bool
    
    init(game: Game, isFavorite: Bool){
        self.game = game
        self.isFavorite = isFavorite
    }
}

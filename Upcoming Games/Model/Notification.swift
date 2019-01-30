//
//  Notification.swift
//  Switch Library
//
//  Created by Eleazar Estrella GB on 1/30/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import Foundation

class Notification {
    var type: String
    var description: String {
        if self.type == "discount" {
            return "\(game.title) has a price discount to $\(game.salePrice)"
        }else if self.type == "releasedGame" {
            return "\(game.title) is releasing on \(game.releaseDate)"
        }else {
            return game.title
        }
    }
    var game: Game
    
    init(userInfo: [AnyHashable : Any]){
        let notificationType = userInfo["notificationType"] as! String
        let jsonDecoder = JSONDecoder()
        let game = try! jsonDecoder.decode(Game.self, from: (userInfo["game"] as! String).data(using: .utf8)!)
        self.type = notificationType
        self.game = game
    }
    
    init(type: String, description: String, game: Game) {
        self.type = type
        self.game = game
    }
}

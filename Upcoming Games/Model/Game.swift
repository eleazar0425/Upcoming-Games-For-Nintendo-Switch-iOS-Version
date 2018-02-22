//
//  Game.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/14/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class Game : Object {
    dynamic var id: String = ""
    dynamic var title: String = ""
    dynamic var releaseDate: String = ""
    dynamic var price: String = "0"
    dynamic var boxArt: String = ""
    dynamic var numberOfPlayers: String = ""
    dynamic var physicalRelease: Bool = false
    

    convenience init(withJSON json: JSON){
        self.init()
        self.id = json["id"].stringValue
        self.title = json["title"].stringValue
        self.releaseDate = json["release_date"].stringValue
        self.price = json["eshop_price"].stringValue
        self.boxArt = json["front_box_art"].stringValue
        self.numberOfPlayers = json["number_of_players"].stringValue
        self.physicalRelease = json["buyitnow"].boolValue
    }
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    class func clone(game: Game) -> Game{
        let clon = Game()
        clon.boxArt = game.boxArt
        clon.id = game.id
        clon.numberOfPlayers = game.numberOfPlayers
        clon.physicalRelease = game.physicalRelease
        clon.price = game.price
        clon.releaseDate = game.releaseDate
        clon.title = game.title
        return clon
    }
}

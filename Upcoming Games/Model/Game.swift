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

class Game : Object, Codable {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var releaseDate: String = ""
    @objc dynamic var price: String = "0"
    @objc dynamic var boxArt: String = ""
    @objc dynamic var numberOfPlayers: String = ""
    @objc dynamic var physicalRelease: Bool = false
    @objc dynamic var salePrice: String = ""
    @objc dynamic var categories: String = ""
    

    convenience init(withJSON json: JSON){
        self.init()
        self.id = json["id"].stringValue
        self.title = json["title"].stringValue
        self.releaseDate = json["release_date"].stringValue
        self.price = json["eshop_price"].stringValue
        self.boxArt = json["front_box_art"].stringValue
        self.numberOfPlayers = json["number_of_players"].stringValue
        self.physicalRelease = json["buyitnow"].boolValue
        self.salePrice = json["sale_price"].stringValue
        let categories = json["categories"]["category"]
        
        if !categories.stringValue.isEmpty {
            self.categories = categories.stringValue
        }else {
            for category in categories {
                self.categories += "\(category.1.stringValue) "
            }
        }
    }
    
    convenience init(id: String){
        self.init()
        self.id = id
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
        clon.salePrice = game.salePrice
        clon.categories = game.categories
        return clon
    }
}

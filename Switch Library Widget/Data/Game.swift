//
//  Game.swift
//  Switch Library Widget
//
//  Created by Eleazar Estrella GB on 3/8/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import Foundation

import Foundation
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
    @objc dynamic var canadaPrice: String = ""

    
    convenience init(id: String){
        self.init()
        self.id = id
    }
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    func discountPercentage() -> Int {
        let usSaleDouble = Double(salePrice)!
        let usDouble = Double(price)!
        return Int( ( (100 - ( (usSaleDouble*100) / usDouble )) ) )
    }
}

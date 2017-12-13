//
//  Favorite.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 8/23/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import Foundation
import RealmSwift

class Favorite : Object {
    dynamic var id: String = ""
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    convenience init(_ id: String) {
        self.init()
        self.id = id
    }
}

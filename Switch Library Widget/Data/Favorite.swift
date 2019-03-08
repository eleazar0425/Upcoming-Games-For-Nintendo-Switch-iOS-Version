//
//  Favorite.swift
//  Switch Library Widget
//
//  Created by Eleazar Estrella GB on 3/8/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import Foundation
import RealmSwift

class Favorite : Object {
    @objc dynamic var id: String = ""
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    convenience init(_ id: String) {
        self.init()
        self.id = id
    }
}

//
//  ServiceError.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/17/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import Foundation
enum ServiceError : Error {
    case unknownError(message: String)
    case noDataAvailable()
}

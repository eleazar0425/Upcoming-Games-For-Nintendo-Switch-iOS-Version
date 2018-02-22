//
//  Client.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/17/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol Client {
    typealias CompletionHandler = (_ response: JSON?, _ error: ServiceError?) -> Void
    
    func request(_ routing: URLRequestConvertible, completion: @escaping CompletionHandler) -> Void
}

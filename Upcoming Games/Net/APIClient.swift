//
//  APIClient.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/17/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIClient : Client {
    
    typealias CompletionHandler = (_ response: JSON?, _ error: ServiceError?) -> Void
    
    func request(_ routing: URLRequestConvertible, completion: @escaping Client.CompletionHandler) {
        Alamofire.request(routing)
            .debugLog()
            .validate()
            .responseJSON { response in
                 guard let result = response.value else {
                    return completion(nil, ServiceError.noDataAvailable())
                }
                completion(JSON(result), nil)
        }
    }
}

extension Request {
    public func debugLog() -> Self {
        #if DEBUG
        debugPrint(self)
        #endif
        return self
    }
}

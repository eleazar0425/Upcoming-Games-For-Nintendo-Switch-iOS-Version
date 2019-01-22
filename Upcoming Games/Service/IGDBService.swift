//
//  IGDBService.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella GB on 1/22/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import Foundation

class IGDBService {
    private let client: Client
    
    typealias CompletionHandler = (_ description: String?, _ error: ServiceError? ) -> Void
    
    required init(client: Client) {
        self.client = client
    }
    
    func getGameDescription(game: Game, completion: @escaping CompletionHandler){
        let route = IGDBRouter.getGameDescription(game: game)
        client.request(route) { (data, serviceError) in
            
            guard let _ = data else { return completion(nil, ServiceError.noDataAvailable()) }
            
            for item in data! {
                let description = item.1["game"]["summary"].stringValue
                if !description.isEmpty {
                    return completion(description, serviceError)
                }
            }
            
            completion("", serviceError)
        }
    }
}

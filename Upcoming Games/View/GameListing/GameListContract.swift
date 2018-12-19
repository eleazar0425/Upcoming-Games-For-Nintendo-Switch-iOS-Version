//
//  GameListContract.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/17/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import Foundation

protocol GameListProtocol {
    func setGameList(games: [Game]?, error: Error?)
}

class GameListPresenter {
    var view: GameListProtocol
    var interactor: GameListInteractor!
    
    init(_ view: GameListProtocol){
        self.view = view
    }
    
    func getGameList(){
        interactor.getGames(completion: { (games, error) in
            self.view.setGameList(games: games, error: error)
        })
    }
    
    
    func order(games: [Game], by: OrderBy) -> [Game]? {
        
        switch by {
            
        case .title:
            return games.sorted {
                return $0.title < $1.title
            }
            
        case .highestPrice:
        return games.sorted {
                guard let price1 = Double($0.price), let price2 = Double($1.price) else {
                    return false
                }
                return price1 >= price2
            }
            
        case .lowestPrice:
            return games.sorted {
                guard let price1 = Double($0.price), let price2 = Double($1.price) else {
                    return false
                }
                return price1 <= price2
            }
            
        case .releaseDate:
            return games.sorted {
                guard let date1 = DateUtil.parse(from: $0.releaseDate),
                    let date2 = DateUtil.parse(from: $1.releaseDate)
                    else { return false }
                return date1 < date2
            }
        }
    }
    
    func filter(games: [Game], by: FilterBy) -> [Game]? {
        
        switch by {
            
        case .sales:
            return games.filter{ game  in
                return !game.salePrice.isEmpty
            }
            
        case .alreadyReleased:
            return games.filter { game in
                return true //TODO complete this
            }
            
        case .physicalOnly:
            return games.filter { game in
                return game.physicalRelease
            }
        
        case .digitalOnly:
            return games.filter { game in
                return !game.physicalRelease
            }
        
        case .notReleased:
            return games.filter { game in
                return true //TODO complete this
            }
            
        case .favorites:
            return games.filter { game in
                return interactor.isFavorite(game.id)
            }
            
        case .all:
            return games
        }
    }
 
    func saveFavorite(id: String){
        interactor.saveFavorite(id)
    }
    
    func deleteFavorite(id: String){
        interactor.deleteFavorite(id)
    }
    
    func isFavorite(id: String) -> Bool {
        return interactor.isFavorite(id)
    }
}

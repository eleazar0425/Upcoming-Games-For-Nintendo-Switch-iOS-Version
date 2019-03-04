//
//  GameDetailContract.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella GB on 1/22/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import Foundation
import Alamofire

protocol GameDetailView {
    func setGameTrailerVideoId(videoId: String?, thumbnail: String?, error: Error?)
    func setGameDescription(description: String?, error: Error?)
}

class GameDetailPresenter {
    var view: GameDetailView
    var youtubeService: YoutubeService!
    var igdbService: IGDBService!
    var interactor: GameListInteractor!
    
    init(view: GameDetailView){
        self.view = view
    }
    
    func getGameTrailer(game: Game){
        youtubeService.getGameTrailer(game: game) { (videoId, thumbnail, error) in
            self.view.setGameTrailerVideoId(videoId: videoId, thumbnail: thumbnail, error: error)
        }
    }
    
    func getGameDescription(game: Game){
        igdbService.getGameDescription(game: game) { (description, error) in
            self.view.setGameDescription(description: description, error: error)
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

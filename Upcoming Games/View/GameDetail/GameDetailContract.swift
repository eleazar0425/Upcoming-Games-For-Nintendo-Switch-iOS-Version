//
//  GameDetailContract.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella GB on 1/22/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import Foundation

protocol GameDetailView {
    func setGameTrailerVideoId(videoId: String?, error: Error?)
    func setGameDescription(description: String?, error: Error?)
}

class GameDetailPresenter {
    var view: GameDetailView
    var youtubeService: YoutubeService!
    var igdbService: IGDBService!
    
    init(view: GameDetailView){
        self.view = view
    }
    
    func getGameTrailer(game: Game){
        youtubeService.getGameTrailer(game: game) { (videoId, error) in
            self.view.setGameTrailerVideoId(videoId: videoId, error: error)
        }
    }
    
    func getGameDescription(game: Game){
        igdbService.getGameDescription(game: game) { (description, error) in
            self.view.setGameDescription(description: description, error: error)
        }
    }
}

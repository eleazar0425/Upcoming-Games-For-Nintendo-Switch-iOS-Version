//
//  NotificationSettingsContract.swift
//  Switch Library Widget
//
//  Created by Eleazar Estrella GB on 3/11/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import Foundation
import FirebaseMessaging

protocol NotificationSettingsView {
    func setGames(games: [Game]?, error: Error?)
}

class NotificationSettingsPresenter {
    var view: NotificationSettingsView
    var interactor: GameLocalDataManager!
    
    init(view: NotificationSettingsView){
        self.view = view
    }
    
    func getGames(){
        let games = interactor.getGames()?.filter { interactor.isFavorite(favorite: Favorite($0.id))}
       view.setGames(
        games: games,
        error: nil)
    }
    
    func suscribe(game: Game){
        Messaging.messaging().subscribe(toTopic: "/topics/"+game.id)
        interactor.saveSuscription(suscription: Suscription(game.id))
    }
    
    func unsuscribe(game: Game){
        Messaging.messaging().unsubscribe(fromTopic: "/topics/"+game.id)
        interactor.deleteSuscription(suscription: Suscription(game.id))
    }
    
    func isSuscribed(game: Game) -> Bool{
        return interactor.isSuscribed(suscription: Suscription(game.id))
    }
}

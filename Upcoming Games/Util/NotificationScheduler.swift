//
//  NotificationScheduler.swift
//  Switch Library
//
//  Created by Eleazar Estrella GB on 3/12/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import Foundation
import FirebaseMessaging

class NotificationScheduler {
    
    var localDataManager: GameLocalDataManager
    
    init(dataManager: GameLocalDataManager){
        self.localDataManager = dataManager
    }
    
    func suscribeGameForNotifications(game: Game, isFavorite: Bool){
        if isFavorite {
            LocalNotificationUtil.scheduleNotification(for: game, notificationType: .releasedGame)
            Messaging.messaging().subscribe(toTopic: "/topics/"+game.id)
            localDataManager.saveSuscription(suscription: Suscription(game.id))
        }else {
            LocalNotificationUtil.removePendingNotifications(to: game)
            Messaging.messaging().unsubscribe(fromTopic: "/topics/"+game.id)
            localDataManager.deleteSuscription(suscription: Suscription(game.id))
        }
    }
}

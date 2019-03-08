//
//  LocalNotificationUtil.swift
//  Switch Library
//
//  Created by Eleazar Estrella GB on 1/30/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import Foundation
import UserNotifications

class LocalNotificationUtil {
    
    static func scheduleNotification(for game: Game, notificationType: GameNotificationType){
        let content = UNMutableNotificationContent()
        content.title = "Beep, boop!"
       
        switch  notificationType {
        case .discountedGame:
            content.body = "\(game.title) has a price discount to $\(game.salePrice) on the eShop now!"
            
        case .releasedGame:
            content.body = "\(game.title) is releasing today!"
        }
        
        content.sound = UNNotificationSound.default
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(game)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        
        content.userInfo = ["game": json ?? "", "notificationType": notificationType.rawValue]
        
        let releaseDate = DateUtil.parse(from: game.releaseDate)!
        
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: releaseDate)
        
        var trigger: UNNotificationTrigger
        switch notificationType {
        case .discountedGame:
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        case .releasedGame:
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        }
        
        var identifier = ""
        
        switch  notificationType {
        case .discountedGame:
            identifier = "FavoriteGameDiscountNotification-\(game.id)"
        case .releasedGame:
            identifier = "FavoriteGameReleasedNotification-\(game.id)"
        }
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("something went wrong!")
            }
        })
    }
    
    static func removePendingNotifications(to game: Game){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["FavoriteGameReleasedNotification-\(game.id)"])
    }
}

enum GameNotificationType: String {
    case releasedGame = "releasedGame"
    case discountedGame = "discount"
}

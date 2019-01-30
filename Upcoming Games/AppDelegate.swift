//
//  AppDelegate.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/14/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import UIKit
import UserNotifications
import Swinject
import SwinjectStoryboard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let center = UNUserNotificationCenter.current()
        
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        let alert = UIAlertController(title: "Please allow us to send you notifications", message: "We need this permission in order to notify you when your favorite games are about to release or are having discounts", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            center.requestAuthorization(options: options) { (granted, error) in
                if !granted {
                    print("Something went wrong!")
                }
            }
        }))
        
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .denied:
                return
            case .notDetermined:
                DispatchQueue.main.async {
                    self.window?.rootViewController?.present(alert, animated: true, completion:nil)
                }
            }
        }
        
        center.delegate = self
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(
            UIApplication.backgroundFetchIntervalMinimum)

        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let interactor = SwinjectStoryboard.defaultContainer.resolve(GameListInteractor.self)!
        interactor.getGames { (games, error) in
            guard let games = games else {
                completionHandler(.noData)
                return
            }
            if error != nil {
                completionHandler(.failed)
            }
            for game in games {
                if interactor.isFavorite(game.id), !game.salePrice.isEmpty {
                    let content = UNMutableNotificationContent()
                    content.title = "Beep, boop!"
                    content.body = "\(game.title) has a price discount to $\(game.salePrice) on the eShop now!"
                    content.sound = UNNotificationSound.default
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try! jsonEncoder.encode(game)
                    let json = String(data: jsonData, encoding: String.Encoding.utf8)
                    content.userInfo = ["game": json ?? "", "notificationType": "discount"]
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,
                                                                    repeats: false)
                    let identifier = "FavoriteGameDiscountNotification-\(game.id)"
                    let request = UNNotificationRequest(identifier: identifier,
                                                        content: content, trigger: trigger)
                    let center = UNUserNotificationCenter.current()
                    center.add(request, withCompletionHandler: { (error) in
                        if error != nil {
                            print("something went wrong!")
                        }
                    })
                }
            }
            completionHandler(.newData)
        }
    }
    

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("\(userInfo)")
    }
}


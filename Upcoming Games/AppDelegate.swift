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
import Firebase
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let center = UNUserNotificationCenter.current()
        
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        
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
        application.registerForRemoteNotifications()

        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                Messaging.messaging().subscribe(toTopic: "/topics/all")
                print("token: \(result.token)")
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().subscribe(toTopic: "/topics/all")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        //print(remoteMessage.appData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //let userInfo = response.notification.request.content.userInfo
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard let gameObject = userInfo["game"] as? String, let notificationType = userInfo["notificationType"] as? String else { return }
        
        let game = Game(withJSON: JSON(gameObject.data(using: .utf8)!))
        
        LocalNotificationUtil.scheduleNotification(for: game, notificationType: GameNotificationType(rawValue: notificationType)!)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        Messaging.messaging().subscribe(toTopic: "/topics/all")
    }
}


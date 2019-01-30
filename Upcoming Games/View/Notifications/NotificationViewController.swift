//
//  NotificationViewController.swift
//  Switch Library
//
//  Created by Eleazar Estrella GB on 1/29/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import UIKit
import UserNotifications
import SwiftEventBus

class NotificationViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var notifications = [Notification]()
    var interactor: GameListInteractor!
    var games: [Game]? {
        didSet {
            guard let games = self.games else { return }
            for game in games {
                if self.interactor.isFavorite(game.id), !game.salePrice.isEmpty {
                    let description = "\(game.title) has a price discount to $\(game.salePrice)"
                    let notificationType = "discount"
                    self.notifications.append(Notification(type: notificationType, description: description, game: game))
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        registerForPreviewing(with: self, sourceView: tableView)
        
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests{
                let userInfo = request.content.userInfo
                let notification = Notification(userInfo: userInfo)
                let game = notification.game
                guard let releaseDate = DateUtil.parse(from: game.releaseDate),
                    let daysToRelease = DateUtil.daysBetweenDates(Date(), releaseDate) else { return }
                if daysToRelease >= 0 {
                    self.notifications.append(notification)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameDetailSegue" {
            let destination = segue.destination as! GameDetailViewController
            let game = sender as! Game
            destination.game = game
        }
    }
}

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "NotificationCellIdentifier"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            as? NotificationTableViewCell else {
                fatalError("The dequeued cell is not an instance of TableViewCell")
        }
        
        let notification = notifications[indexPath.row]
        
        cell.descriptionLabel.text = notification.description
        cell.boxArt.setImage(withPath: notification.game.boxArt)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = self.notifications[indexPath.row].game
        performSegue(withIdentifier: "gameDetailSegue", sender: game)
    }
}

extension NotificationViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        let viewController = storyboard?.instantiateViewController(withIdentifier: "gameDetailViewController") as! GameDetailViewController
        viewController.game = self.notifications[indexPath.row].game
        return viewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

//
//  GamesViewController.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/14/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import UIKit
import Toast_Swift
import UserNotifications
import HGPlaceholders
import SwiftEventBus

class GamesViewController: UIViewController {

    @IBOutlet weak var tableView: TableView!
    
    var games = [Game]()
    var backup: [Game]?
    
    var filterState: FilterBy = .all
    var orderByState: OrderBy = .releaseDate
    
    var presenter: GameListPresenter!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(GamesViewController.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.orange
        
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.placeholderDelegate = self
        tableView.refreshControl = refreshControl
        let nib = UINib.init(nibName: "GameViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "GameCellIdentifier")
        
        registerForPreviewing(with: self, sourceView: tableView)
        
        SwiftEventBus.onMainThread(self, name: "favoritesUpdate") { result in
            let event = result?.object as! FavoriteEvent
            guard let index = self.games.firstIndex(of: event.game) else { return }
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        
        prepareActivityIndicator()
        //activityIndicator.startAnimating()
        tableView.showLoadingPlaceholder()
        presenter.getGameList()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameDetailSegue" {
            let destination = segue.destination as! GameDetailViewController
            let game = sender as! Game
            destination.game = game
        }
    }
    
    func prepareActivityIndicator(){
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        presenter.getGameList()
    }
    
    
    @IBAction func sortAction(_ sender: Any) {
         let alertController = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        
        let byTitle = UIAlertAction(title: "Title", style: .default) { _ in
            self.order(by: .title)
        }
        
        let byDate = UIAlertAction(title: "Release date", style: .default) { _ in
            self.order(by: .releaseDate)
        }
        
        let byHighestPrice = UIAlertAction(title: "Highest price", style: .default) { _ in
            self.order(by: .highestPrice)
        }
        
        let byLowestPrice = UIAlertAction(title: "Lowest price", style: .default) { _ in
            self.order(by: .lowestPrice)
        }
        
        alertController.addAction(byTitle)
        alertController.addAction(byDate)
        alertController.addAction(byLowestPrice)
        alertController.addAction(byHighestPrice)
        
        alertController.popoverPresentationController?.sourceView = self.view  // works for both iPhone & iPad
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func filterAction(_ sender: Any) {
       
        let alertController = UIAlertController(title: "Filter by", message: nil, preferredStyle: .actionSheet)
        
        let sales = UIAlertAction(title: "Games on sales", style: .default) { _ in
            self.filter(by: .sales)
        }
       
        let filterPhysicalOnly = UIAlertAction(title: "Digital only", style: .default) { _ in
            self.filter(by: .digitalOnly)
        }
        
        let filterDigitalOnly = UIAlertAction(title: "Physical only", style: .default) { _ in
            self.filter(by: .physicalOnly)
        }
        
        let filterFavorites = UIAlertAction(title: "Favorites", style: .default) { _ in
            self.filter(by: .favorites)
        }
        
        let filterAll = UIAlertAction(title: "All", style: .default) { _ in
            self.filter(by: .all)
        }
        
        alertController.addAction(sales)
        alertController.addAction(filterAll)
        alertController.addAction(filterFavorites)
        alertController.addAction(filterPhysicalOnly)
        alertController.addAction(filterDigitalOnly)
        
        alertController.popoverPresentationController?.sourceView = self.view  // works for both iPhone & iPad

        self.present(alertController, animated: true, completion: nil)
    }
}

extension GamesViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = self.games[indexPath.row]
        performSegue(withIdentifier: "gameDetailSegue", sender: game)
    }
}

extension GamesViewController : UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "GameCellIdentifier"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                as? GameTableViewCell else {
            fatalError("The dequeued cell is not an instance of TableViewCell")
        }
        
        let game = games[indexPath.row]
        
        cell.title.text = game.title
        cell.releaseOn.text = game.releaseDate
        cell.boxArt.setImage(withPath: game.boxArt, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        cell.price.text = (game.price != "" ? "$\(game.price)": "TBA" )
        
        let salePrice = game.salePrice
        if !salePrice.isEmpty {
            cell.hasSalePrice = true
            cell.salePrice.text = "$\(salePrice)"
        }else{
            cell.hasSalePrice = false
        }
        
        cell.physicalRelease.text = "Physical release: \(game.physicalRelease ? "Yes" : "No")"
        
        guard let releaseDate = DateUtil.parse(from: game.releaseDate),
              let daysToRelease = DateUtil.daysBetweenDates(Date(), releaseDate) else {
            return cell
        }
        
        if daysToRelease > 0 {
            cell.daysToRelease.text = "\(daysToRelease) \(daysToRelease == 1 ? "day" : "days") to release"
        }else{
            cell.daysToRelease.text = "Already released"
        }
        
        cell.indexPath = indexPath
        cell.favorite = presenter.isFavorite(id: game.id)
        cell.delegate = self
    
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
}

extension GamesViewController: ToggleFavoriteDelegate {
    func setFavorite(at index: IndexPath, isFavorite: Bool) {
        let game = games[index.row]
        var message = ""
        if isFavorite {
            presenter.saveFavorite(id: game.id)
            message = "\(game.title) has been added to favorites"
            let content = UNMutableNotificationContent()
            content.title = "Beep, boop!"
            content.body = "\(game.title) is releasing today!"
            content.sound = UNNotificationSound.default
            let jsonEncoder = JSONEncoder()
            let jsonData = try! jsonEncoder.encode(game)
            let json = String(data: jsonData, encoding: String.Encoding.utf8)
            content.userInfo = ["game": json ?? "", "notificationType": "releasedGame"]
            
            let releaseDate = DateUtil.parse(from: game.releaseDate)!
            
            let calendar = Calendar.current
            
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: releaseDate)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let identifier = "FavoriteGameReleasedNotification-\(game.id)"
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request, withCompletionHandler: { (error) in
                if error != nil {
                    print("something went wrong!")
                }
            })
        }else{
            presenter.deleteFavorite(id: game.id)
            message = "\(game.title) has been removed from favorites"
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["FavoriteGameReleasedNotification-\(game.id)"])
        }
        
        SwiftEventBus.post("favoritesUpdate", sender: FavoriteEvent(game: game, isFavorite: isFavorite))
        
        self.view.makeToast(message)
    }
    
    func setFavorite(game: Game, isFavorite: Bool) {
        guard let index = games.firstIndex(of: game) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        self.setFavorite(at: indexPath, isFavorite: isFavorite)
    }
}

extension GamesViewController : GameListProtocol {
    func setGameList(games: [Game]?, error: Error?){
        guard let gamesResult = games else {
            return showErrorMessage()
        }
        
        guard error == nil else {
            return showErrorMessage()
        }
        
        guard !gamesResult.isEmpty else {
            tableView.showErrorPlaceholder()
            tableView.reloadData()
            refreshControl.endRefreshing()
            return
        }
        
        self.games.removeAll()
        self.games += gamesResult
        self.backup = games
        tableView.reloadData()
        tableView.showDefault()
        refreshControl.endRefreshing()
        order(by: orderByState)
        filter(by: filterState)
        
        let searchController = (self.tabBarController?.viewControllers?[1] as! UINavigationController).viewControllers[0] as! SearchViewController
        
        let notificationController = (self.tabBarController?.viewControllers?[2] as! UINavigationController).viewControllers[0] as! NotificationViewController
        
        searchController.games = self.games
        notificationController.games = self.games
    }
    
    func showErrorMessage(){
        /*let alert = UIAlertController(title: "Error", message: "There was an error, plase try again later", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.activityIndicator.stopAnimating()*/
        self.refreshControl.endRefreshing()
        self.tableView.showNoConnectionPlaceholder()
    }
    
    func order(by: OrderBy, fromFilter: Bool = false){
        guard let sortedGames =  presenter.order(games: games, by: by) else { return }
        self.games = sortedGames
        self.orderByState = by
        if !fromFilter {
            filter(by: filterState, fromOrderBy: true)
        }
        self.tableView.reloadData()
        
        if case .releaseDate = self.orderByState {
            let firstTodayRelease = self.games.first { game -> Bool in
                let today = Date.init()
                let gameDate = DateUtil.parse(from: game.releaseDate)!
                return DateUtil.daysBetweenDates(today, gameDate)! >= 0
            }
            
            var index = 0
            
            if self.games.count > 0 {
                index = (self.games.count) - 1
            }
            
            if firstTodayRelease != nil {
                index = self.games.firstIndex(of: firstTodayRelease!) ?? 0
            }
            
            let deadlineTime = DispatchTime.now() + .seconds(1)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                if self.tableView.numberOfSections > 0, self.tableView.numberOfRows(inSection: 0) > index {
                    self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
                }
            }
        }
    }
    
    func filter(by: FilterBy, fromOrderBy: Bool = false){
        guard let filteredGames = presenter.filter(games: self.backup!, by: by) else { return }
        
        guard by != .all else {
            if let backupGames = self.backup {
                self.games = backupGames
                order(by: orderByState, fromFilter: true)
                self.filterState = by
                self.tableView.reloadData()
            }
            return
        }
        
        self.games = filteredGames
        if !fromOrderBy {
            order(by: orderByState, fromFilter: true)
        }
        self.filterState = by
        self.tableView.reloadData()
        
        if self.games.isEmpty {
            self.tableView.showNoResultsPlaceholder()
        }
    }
}

extension GamesViewController: PlaceholderDelegate {
    func view(_ view: Any, actionButtonTappedFor placeholder: Placeholder) {
        switch placeholder.key {
        case PlaceholderKey.noConnectionKey, PlaceholderKey.noResultsKey, PlaceholderKey.errorKey:
            self.tableView.showLoadingPlaceholder()
            self.presenter.getGameList()
        default:
            return
        }
    }
}

extension GamesViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        let viewController = storyboard?.instantiateViewController(withIdentifier: "gameDetailViewController") as! GameDetailViewController
        viewController.game = self.games[indexPath.row]
        return viewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}
